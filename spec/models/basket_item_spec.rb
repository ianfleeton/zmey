require 'rails_helper'

RSpec.describe BasketItem, type: :model do
  describe '#line_total(inc_tax)' do
    context 'when inc_tax is true' do
      it 'returns the quantity times the price of the product including tax when buying that quantity' do
        product = FactoryBot.build(:product)
        item = BasketItem.new(quantity: 2)
        allow(item).to receive(:product_price_inc_tax).and_return(12)
        item.product = product
        expect(item.line_total(true)).to eq 24
      end
    end

    context 'when inc_tax is false' do
      it 'returns the quantity times the price of the product excluding tax when buying that quantity' do
        product = FactoryBot.build(:product)
        item = BasketItem.new(quantity: 2)
        allow(item).to receive(:product_price_ex_tax).and_return(10)
        item.product = product
        expect(item.line_total(false)).to eq 20
      end
    end
  end

  describe '#tax_amount' do
    it 'returns the total amount of tax' do
      product = FactoryBot.create(:product, tax_type: Product::EX_VAT, price: 1)
      basket_item = BasketItem.new(product: product, quantity: 3)
      expect(basket_item.tax_amount).to be_within(0.0001).of(1 * 3 * Product::VAT_RATE)
    end
  end

  describe '#savings' do
    let(:inc_tax) { false }
    let(:basket_item) { FactoryBot.build(:basket_item, product: product, quantity: quantity) }

    subject { basket_item.savings(inc_tax) }

    context 'with 1 item, RRP unset' do
      let(:quantity) { 1 }
      let(:product) { FactoryBot.create(:product, rrp: nil, price: 1.0) }
      it { should eq 0 }
    end

    context 'with 1 item, RRP set to 1.0 more' do
      let(:quantity) { 1 }
      let(:product) { FactoryBot.create(:product, rrp: 2.0, price: 1.0, tax_type: tax_type) }

      context 'product price ex VAT' do
        let(:tax_type) { Product::EX_VAT }
        it { should eq 1.0 }
      end

      context 'product price inc VAT' do
        let(:tax_type) { Product::INC_VAT }
        it { should be_within(0.0001).of(0.8333) }
      end
    end

    context 'with 2 items, RRP set to 1.0 more' do
      let(:quantity) { 2 }
      let(:product) { FactoryBot.create(:product, rrp: 2.0, price: 1.0) }
      it { should eq 2.0 }
    end

    context 'with 5 items, RRP unset, volume purchase price at 0.50 less' do
      let(:quantity) { 5 }
      let(:product) { FactoryBot.create(:product, rrp: nil, price: 2.0) }

      before do
        # Make sure we're using QuantityBased price calculations.
        expect(product).to receive(:price_calculator_class).and_return(PriceCalculator::QuantityBased)
        QuantityPrice.create(quantity: 5, price: 1.5, product: product)
      end

      it { should eq 2.5 }
    end

    context 'inc tax, 1 product, RRP is 2.0, price is 1.0' do
      let(:inc_tax) { true }
      let(:product) { FactoryBot.create(:product, rrp: 2.0, price: 1.0, tax_type: tax_type) }
      let(:quantity) { 1 }

      context 'product price excludes VAT' do
        let(:tax_type) { Product::EX_VAT }
        it { should eq 1.0 * (1 + Product::VAT_RATE) }
      end

      context 'product price includes VAT' do
        let(:tax_type) { Product::INC_VAT }
        it { should eq 1.0 }
      end
    end
  end

  describe '#price_calculator' do
    it 'gets a price calculator from the product' do
      quantity = 3
      product = Product.new
      calculator = double(PriceCalculator::Base)
      basket_item = BasketItem.new(product: product, quantity: quantity)
      allow(product).to receive(:price_calculator).with(hash_including(basket_item: basket_item, quantity: quantity)).and_return(calculator)
      expect(basket_item.price_calculator).to eq calculator
    end
  end

  describe '#product_price_inc_tax' do
    it 'gets a price inc tax from the calculator' do
      basket_item = BasketItem.new
      calculator = double(PriceCalculator::Base, inc_tax: 123)
      allow(basket_item).to receive(:price_calculator).and_return calculator
      expect(basket_item.product_price_inc_tax).to eq 123
    end
  end

  describe '#product_price_ex_tax' do
    it 'gets a price ex tax from the calculator' do
      basket_item = BasketItem.new
      calculator = double(PriceCalculator::Base, ex_tax: 123)
      allow(basket_item).to receive(:price_calculator).and_return calculator
      expect(basket_item.product_price_ex_tax).to eq 123
    end
  end

  describe '#adjust_quantity' do
    let(:basket_item) { FactoryBot.build(:basket_item, product_id: product.id) }

    before do
      basket_item.quantity = 1.6
      basket_item.save
    end

    context 'when product allows fractional quantity' do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }

      it 'leaves the quantity as a decimal' do
        expect(basket_item.reload.quantity).to eq 1.6
      end
    end

    context 'when product disallows fractional quantity' do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }

      it 'rounds the quantity up' do
        expect(basket_item.reload.quantity).to eq 2
      end
    end
  end

  describe '#counting_quantity' do
    let(:basket_item) { BasketItem.new(product: product, quantity: quantity) }

    context 'with product allowing fractional quantity' do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }
      let(:quantity) { 2.5 }

      it 'returns 1' do
        expect(basket_item.counting_quantity).to eq 1
      end
    end

    context 'with product disallowing fractional quantity' do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }
      let(:quantity) { 2 }

      it 'returns quantity' do
        expect(basket_item.counting_quantity).to eq 2
      end

      it 'returns an integer' do
        expect(basket_item.counting_quantity).to be_kind_of(Integer)
      end
    end
  end

  describe '#display_quantity' do
    let(:basket_item) { BasketItem.new(product: product, quantity: quantity) }

    context 'with product allowing fractional quantity' do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }
      let(:quantity) { 2.5 }

      it 'returns a decimal' do
        expect(basket_item.display_quantity).to eq 2.5
      end
    end

    context 'with product disallowing fractional quantity' do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }
      let(:quantity) { 2 }

      it 'returns an integer' do
        expect(basket_item.display_quantity).to eq 2
        expect(basket_item.display_quantity.kind_of?(Integer)).to be_truthy
      end
    end
  end

  describe '#weight' do
    it 'returns the weight of the product times the quantity' do
      product = FactoryBot.build(:product, weight: 2.5)
      item = BasketItem.new(quantity: 3)
      item.product = product
      expect(item.weight).to eq 7.5
    end
  end

  describe '#preserve_immutable_quantity' do
    it 'allows quantity to change when mutable' do
      item = FactoryBot.create(:basket_item, immutable_quantity: false, quantity: 1)
      item.quantity = 2
      item.save
      item.reload
      expect(item.quantity).to eq 2
    end

    it 'prevents quantity from changing when immutable' do
      item = FactoryBot.create(:basket_item, immutable_quantity: true, quantity: 1)
      item.quantity = 2
      item.save
      item.reload
      expect(item.quantity).to eq 1
    end

    it 'prevents immutable_quantity from changing back to false once true' do
      item = FactoryBot.create(:basket_item, immutable_quantity: true)
      item.immutable_quantity = false
      item.quantity = 2
      item.save
      item.reload
      expect(item.quantity).to eq 1
      expect(item.immutable_quantity?).to be_truthy
    end
  end

  describe '#oversize?' do
    subject { BasketItem.new(product: product).oversize? }

    context 'with oversize product' do
      let(:product) { FactoryBot.create(:product, oversize: true) }
      it { should eq true }
    end

    context 'with normal size product' do
      let(:product) { FactoryBot.create(:product, oversize: false) }
      it { should eq false }
    end

    context 'with no product' do
      let(:product) { nil }
      it { should be_falsey }
    end
  end

  describe '#deep_clone' do
    it 'returns a copy of the basket item with feature selections' do
      feature = FactoryBot.create(:feature)
      bi = FactoryBot.create(:basket_item, quantity: 123)
      bi.feature_selections << FeatureSelection.create(
        feature: feature, customer_text: 'deep clone selection'
      )
      bi2 = bi.deep_clone
      expect(bi2).not_to eq bi
      expect(bi2.quantity).to eq 123
      expect(bi2.feature_selections.count).to eq 1
      expect(bi2.feature_selections.first.customer_text).to eq 'deep clone selection'
      expect(bi2.feature_selections.first).not_to eq bi.feature_selections.first
    end
  end
end
