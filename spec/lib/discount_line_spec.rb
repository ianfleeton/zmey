# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscountLine do
  subject { DiscountLine.new(nil, {}) }
  it { should respond_to :mutually_exclusive_with }

  describe "#initialize" do
    it "sets its calculator to the provided attrs param" do
      calculator = instance_double(Discounts::Calculators::FreeProducts)
      discount_line = DiscountLine.new(nil, calculator: calculator)
      expect(discount_line.calculator).to eq calculator
    end
  end

  describe "#price_with_vat" do
    context "when param is true" do
      it "returns sum of price adjustment and tax adjustment" do
        dl = DiscountLine.new(nil, price_adjustment: 10, tax_adjustment: 5)
        result = dl.price_with_vat(true)
        expect(result).to eq 15
      end
    end

    context "when param is false" do
      it "returns price adjustment" do
        dl = DiscountLine.new(nil, price_adjustment: 10, tax_adjustment: 5)
        result = dl.price_with_vat(false)
        expect(result).to eq 10
      end
    end
  end

  describe "#price_adjustment=" do
    it "rounds to 2dp" do
      dl = DiscountLine.new(nil, {})
      dl.price_adjustment = 1.235
      expect(dl.price_adjustment).to eq 1.24
    end
  end

  describe "#tax_adjustment=" do
    it "rounds to 2dp" do
      dl = DiscountLine.new(nil, {})
      dl.tax_adjustment = 1.235
      expect(dl.tax_adjustment).to eq 1.24
    end
  end

  describe "#to_s" do
    it "return name, price adjustment and tax adjustment" do
      dl = DiscountLine.new(nil, name: "dl_1", price_adjustment: 10, tax_adjustment: 5)
      expect(dl.to_s).to eq "dl_1: 10.0 5.0"
    end
  end

  describe "#to_order_line" do
    let(:discount_line) do
      DiscountLine.new(
        nil, name: "SAVE10", price_adjustment: -10, tax_adjustment: -2
      )
    end

    let(:order_line) { discount_line.to_order_line }

    it "sets product_id to 0" do
      expect(order_line.product_id).to eq 0
    end

    it "sets product_sku" do
      expect(order_line.product_sku).to eq DiscountLine::SKU
    end

    it "sets product_name to the name of the discount line" do
      expect(order_line.product_name).to eq "SAVE10"
    end

    it "sets the product_price to price_adjustment" do
      expect(order_line.product_price).to eq(-10)
    end

    it "sets the vat_amount to tax_adjustment" do
      expect(order_line.vat_amount).to eq(-2)
    end

    it "sets the quantity to 1" do
      expect(order_line.quantity).to eq 1
    end
  end
end
