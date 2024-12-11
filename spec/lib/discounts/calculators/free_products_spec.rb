# frozen_string_literal: true

require "rails_helper"

module Discounts
  module Calculators
    RSpec.describe FreeProducts do
      before { allow(Product).to receive(:vat_rate).and_return(BigDecimal("0.2")) }

      it "adds a free item to the basket when threshold met" do
        products = [Product.new(name: "Notebook", price: BigDecimal("1.66"), tax_type: Product::EX_VAT)]
        discount = instance_double(Discount, threshold: BigDecimal(10), products: products)
        basket = instance_double(Basket)
        et = instance_double(EffectiveTotal, ex_vat: BigDecimal(10))
        allow(EffectiveTotal).to receive(:new).with(discount, basket).and_return(et)
        calculator = Calculator.new([], basket)
        free_products = FreeProducts.new(calculator, discount)
        free_products.calculate
        expect(calculator.discount_lines.length).to eq 1
        discount_line = calculator.discount_lines.first
        expect(discount_line.name).to eq "Free Notebook"
        expect(discount_line.price_adjustment).to eq BigDecimal("-1.66")
        expect(discount_line.tax_adjustment).to eq BigDecimal("-0.33")
      end

      it "adds multiple free items to the basket when threshold met" do
        skip
        products = [
          Product.new(name: "Notebook", price: BigDecimal("1.66")),
          Product.new(name: "Pen", price: BigDecimal("1.05"))
        ]
        discount = instance_double(Discount, threshold: BigDecimal(10), products: products)
        basket = instance_double(Basket)
        et = instance_double(EffectiveTotal, ex_vat: BigDecimal(10))
        allow(EffectiveTotal).to receive(:new).with(discount, basket).and_return(et)
        calculator = Calculator.new([], basket)
        free_products = FreeProducts.new(calculator, discount)
        free_products.calculate
        expect(calculator.discount_lines.length).to eq 1
        discount_line = calculator.discount_lines.first
        expect(discount_line.name).to eq "Free Notebook & Pen"
        expect(discount_line.price_adjustment).to eq BigDecimal("-2.71")
        expect(discount_line.tax_adjustment).to eq BigDecimal("-0.54")
      end

      it "adds nothing to the basket when threshold is not met" do
        skip
        products = [Product.new(name: "Notebook", price: BigDecimal("1.66"))]
        discount = instance_double(Discount, threshold: BigDecimal(11), products: products)
        basket = instance_double(Basket)
        et = instance_double(EffectiveTotal, ex_vat: BigDecimal(10))
        allow(EffectiveTotal).to receive(:new).with(discount, basket).and_return(et)
        calculator = Calculator.new([], basket)
        free_products = FreeProducts.new(calculator, discount)
        free_products.calculate
        expect(calculator.discount_lines.length).to be_zero
      end
    end
  end
end
