# frozen_string_literal: true

require "rails_helper"

module Discounts
  RSpec.describe EffectiveTotal do
    describe "#inspect" do
      it "returns key calculations formatted" do
        et = EffectiveTotal.new(Discount.new, Basket.new)
        expect(et.inspect).to eq "#<EffectiveTotal ex_vat: 0, inc_vat: 0, vat_amount: 0, vat_rate: 0>"
      end
    end

    describe "#ex_vat" do
      it "returns the basket total excluding vat minus reward items total" do
        discount = instance_double(Discount, exclude_reduced_products?: false)
        basket = instance_double(Basket)
        allow(basket).to receive(:total).with(false).and_return(BigDecimal("1.23"))
        allow(basket).to receive(:reward_items_total).with(inc_vat: false).and_return(BigDecimal("0.45"))
        et = EffectiveTotal.new(discount, basket)
        expect(et.ex_vat).to eq BigDecimal("0.78")
      end
    end

    describe "#inc_vat" do
      it "returns the basket total including vat minus reward items total" do
        discount = instance_double(Discount, exclude_reduced_products?: false)
        basket = instance_double(Basket)
        allow(basket).to receive(:total).with(true).and_return(BigDecimal("1.23"))
        allow(basket).to receive(:reward_items_total).with(inc_vat: true).and_return(BigDecimal("0.45"))
        et = EffectiveTotal.new(discount, basket)
        expect(et.inc_vat).to eq BigDecimal("0.78")
      end
    end
  end
end
