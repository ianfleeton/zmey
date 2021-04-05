require "rails_helper"

RSpec.describe OrderLine, type: :model do
  describe "validations" do
    it do
      should(
        validate_numericality_of(:product_price)
          .is_greater_than_or_equal_to(-Product::MAX_PRICE)
          .is_less_than_or_equal_to(Product::MAX_PRICE)
      )
    end
    it do
      should(
        validate_numericality_of(:quantity)
          .is_greater_than(0)
          .is_less_than_or_equal_to(10_000)
      )
    end
  end

  describe "#to_s" do
    it "returns quantity × product_name" do
      ol = OrderLine.new(quantity: 2, product_name: "Widget")
      expect(ol.to_s).to eq "2.0 × Widget"
    end
  end

  describe "#line_total_net" do
    it "returns the product price times the quantity" do
      ol = OrderLine.new(product_price: 1.25, quantity: 3)
      expect(ol.line_total_net).to be_within(0.001).of(3.75)
    end
  end

  describe "#product_vat_amount" do
    it "returns the line VAT amount / quantity" do
      ol = OrderLine.new(product_price: 7, quantity: 3, vat_amount: 4.2)
      expect(ol.product_vat_amount).to eq 1.4
    end
  end

  describe "#product_price_inc_vat" do
    it "returns the product price including VAT" do
      ol = OrderLine.new(product_price: 7, quantity: 1, vat_amount: 1.4)
      expect(ol.product_price_inc_vat).to eq 8.4
    end
  end

  describe "#vat_percentage" do
    it "returns 0 when the line total is 0" do
      o = OrderLine.new(product_price: 0, quantity: 2)
      expect(o.vat_percentage).to eq 0.0
    end

    it "returns 20 when the line total is 10 and VAT amount 2" do
      o = OrderLine.new(product_price: 5, quantity: 2, vat_amount: 2)
      expect(o.vat_percentage).to eq 20.0
    end
  end

  describe "#lead_time" do
    it "returns 0 without a product" do
      expect(OrderLine.new.lead_time).to be_zero
    end

    it "delegates to its product" do
      product = Product.new(lead_time: 3)
      line = OrderLine.new(product: product)
      expect(line.lead_time).to eq 3
    end
  end

  describe "#display_quantity" do
    let(:order_line) { OrderLine.new(product: product, quantity: quantity) }

    context "with product allowing fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: true) }
      let(:quantity) { 2.5 }

      it "returns a decimal" do
        expect(order_line.display_quantity).to eq 2.5
      end
    end

    context "with product disallowing fractional quantity" do
      let(:product) { FactoryBot.create(:product, allow_fractional_quantity: false) }
      let(:quantity) { 2 }

      it "returns an integer" do
        expect(order_line.display_quantity).to eq 2
        expect(order_line.display_quantity.is_a?(Integer)).to be_truthy
      end
    end

    context "with no product" do
      let(:product) { nil }
      let(:quantity) { 2 }

      it "returns an integer" do
        expect(order_line.display_quantity).to eq 2
        expect(order_line.display_quantity.is_a?(Integer)).to be_truthy
      end
    end
  end
end
