require "rails_helper"

RSpec.describe BasketItem, type: :model do
  describe "delegated methods" do
    it { should delegate_method(:delivery_cutoff_hour).to(:product) }
  end

  describe "#line_total(inc_tax)" do
    context "when inc_tax is true" do
      it "returns the quantity times the price of the product including tax when buying that quantity" do
        product = FactoryBot.build(:product)
        item = BasketItem.new(quantity: 2)
        allow(item).to receive(:product_price_inc_tax).and_return(12)
        item.product = product
        expect(item.line_total(true)).to eq 24
      end
    end

    context "when inc_tax is false" do
      it "returns the quantity times the price of the product excluding tax when buying that quantity" do
        product = FactoryBot.build(:product)
        item = BasketItem.new(quantity: 2)
        allow(item).to receive(:product_price_ex_tax).and_return(10)
        item.product = product
        expect(item.line_total(false)).to eq 20
      end
    end
  end

  describe "#tax_amount" do
    it "returns the total amount of tax" do
      product = FactoryBot.create(:product, tax_type: Product::EX_VAT, price: 1)
      basket_item = BasketItem.new(product: product, quantity: 3)
      expect(basket_item.tax_amount).to be_within(0.0001).of(1 * 3 * Product::VAT_RATE)
    end
  end

  describe "#savings" do
    it "delegates to the price calculator" do
      calc = instance_double(PriceCalculator::Base)
      expect(calc).to receive(:savings).with(inc_tax: false).and_return(3.5)
      @object = BasketItem.new
      allow(@object).to receive(:price_calculator).and_return(calc)
      expect(@object.savings(inc_tax: false)).to eq 3.5
    end
  end

  describe "#price_calculator" do
    it "gets a price calculator from the product" do
      quantity = 3
      product = Product.new
      calculator = double(PriceCalculator::Base)
      basket_item = BasketItem.new(product: product, quantity: quantity)
      allow(product).to receive(:price_calculator).with(hash_including(basket_item: basket_item, quantity: quantity)).and_return(calculator)
      expect(basket_item.price_calculator).to eq calculator
    end
  end

  describe "#product_price_inc_tax" do
    it "gets a price inc tax from the calculator" do
      basket_item = BasketItem.new
      calculator = double(PriceCalculator::Base, inc_tax: 123)
      allow(basket_item).to receive(:price_calculator).and_return calculator
      expect(basket_item.product_price_inc_tax).to eq 123
    end
  end

  describe "#product_price_ex_tax" do
    it "gets a price ex tax from the calculator" do
      basket_item = BasketItem.new
      calculator = double(PriceCalculator::Base, ex_tax: 123)
      allow(basket_item).to receive(:price_calculator).and_return calculator
      expect(basket_item.product_price_ex_tax).to eq 123
    end
  end

  describe "#adjust_quantity" do
    let(:basket_item) { FactoryBot.build(:basket_item, product_id: product.id) }

    before do
      basket_item.quantity = 1.6
      basket_item.save
    end

    context "when product allows fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }

      it "leaves the quantity as a decimal" do
        expect(basket_item.reload.quantity).to eq 1.6
      end
    end

    context "when product disallows fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }

      it "rounds the quantity up" do
        expect(basket_item.reload.quantity).to eq 2
      end
    end
  end

  describe "#counting_quantity" do
    let(:basket_item) { BasketItem.new(product: product, quantity: quantity) }

    context "with product allowing fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }
      let(:quantity) { 2.5 }

      it "returns 1" do
        expect(basket_item.counting_quantity).to eq 1
      end
    end

    context "with product disallowing fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }
      let(:quantity) { 2 }

      it "returns quantity" do
        expect(basket_item.counting_quantity).to eq 2
      end

      it "returns an integer" do
        expect(basket_item.counting_quantity).to be_kind_of(Integer)
      end
    end
  end

  describe "#display_quantity" do
    let(:basket_item) { BasketItem.new(product: product, quantity: quantity) }

    context "with product allowing fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }
      let(:quantity) { 2.5 }

      it "returns a decimal" do
        expect(basket_item.display_quantity).to eq 2.5
      end
    end

    context "with product disallowing fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }
      let(:quantity) { 2 }

      it "returns an integer" do
        expect(basket_item.display_quantity).to eq 2
        expect(basket_item.display_quantity.is_a?(Integer)).to be_truthy
      end
    end
  end

  describe "#weight" do
    it "returns the weight of the product times the quantity" do
      product = FactoryBot.build(:product, weight: 2.5)
      item = BasketItem.new(quantity: 3)
      item.product = product
      expect(item.weight).to eq 7.5
    end
  end

  describe "#preserve_immutable_quantity" do
    it "allows quantity to change when mutable" do
      item = FactoryBot.create(:basket_item, immutable_quantity: false, quantity: 1)
      item.quantity = 2
      item.save
      item.reload
      expect(item.quantity).to eq 2
    end

    it "prevents quantity from changing when immutable" do
      item = FactoryBot.create(:basket_item, immutable_quantity: true, quantity: 1)
      item.quantity = 2
      item.save
      item.reload
      expect(item.quantity).to eq 1
    end

    it "prevents immutable_quantity from changing back to false once true" do
      item = FactoryBot.create(:basket_item, immutable_quantity: true)
      item.immutable_quantity = false
      item.quantity = 2
      item.save
      item.reload
      expect(item.quantity).to eq 1
      expect(item.immutable_quantity?).to be_truthy
    end
  end

  describe "#oversize?" do
    subject { BasketItem.new(product: product).oversize? }

    context "with oversize product" do
      let(:product) { FactoryBot.create(:product, oversize: true) }
      it { should eq true }
    end

    context "with normal size product" do
      let(:product) { FactoryBot.create(:product, oversize: false) }
      it { should eq false }
    end

    context "with no product" do
      let(:product) { nil }
      it { should be_falsey }
    end
  end

  describe "#deep_clone" do
    it "returns a copy of the basket item with feature selections" do
      feature = FactoryBot.create(:feature)
      bi = FactoryBot.create(:basket_item, quantity: 123)
      bi.feature_selections << FeatureSelection.create(
        feature: feature, customer_text: "deep clone selection"
      )
      bi2 = bi.deep_clone
      expect(bi2).not_to eq bi
      expect(bi2.quantity).to eq 123
      expect(bi2.feature_selections.count).to eq 1
      expect(bi2.feature_selections.first.customer_text).to eq "deep clone selection"
      expect(bi2.feature_selections.first).not_to eq bi.feature_selections.first
    end
  end

  describe "#to_order_line" do
    let(:calc) do
      instance_double(
        PriceCalculator::Base, ex_tax: 1.23, inc_tax: 1.48, weight: 0.5
      )
    end
    let(:product) { Product.new(id: 123, rrp: 2.34, sku: "sku", name: "Short Tee 101", brand: "Interclamp") }
    let(:item) { BasketItem.new(product: product, quantity: 3) }
    let(:order) { Order.new }
    let(:line) { item.to_order_line }

    before do
      allow(product).to receive(:price_calculator).and_return(calc)
    end

    it "sets product id" do
      expect(line.product_id).to eq product.id
    end

    it "sets product sku" do
      expect(line.product_sku).to eq product.sku
    end

    it "sets product name" do
      expect(line.product_name).to eq "Short Tee 101"
    end

    it "sets product brand" do
      expect(line.product_brand).to eq "Interclamp"
    end

    it "sets product RRP" do
      expect(line.product_rrp).to eq product.rrp
    end

    it "sets the price ex tax for a single product" do
      expect(line.product_price).to eq 1.23
    end

    it "sets the weight for a single product" do
      expect(line.weight).to eq 1.5
    end

    it "sets the tax amount of the line total" do
      expect(line.tax_amount).to eq 0.75
    end

    it "sets quantity" do
      expect(line.quantity).to eq 3
    end
  end
end
