# frozen_string_literal: true

require "rails_helper"

module Discounts
  RSpec.describe Calculator do
    describe "#initialize" do
      it "takes two parameters" do
        Calculator.new([Discount.new], Basket.new)
      end

      it "sets @basket to basket" do
        c = Calculator.new([], basket = Basket.new)
        expect(c.basket).to eq basket
      end

      it "sets @discounts to discounts" do
        c = Calculator.new([discount = Discount.new], Basket.new)
        expect(c.discounts).to eq [discount]
      end
    end

    describe "#calculate" do
      let(:discount) { Discount.new }
      let(:discounts) { [discount] }
      let(:c) { Calculator.new(discounts, Basket.new) }

      class FakeCalculator
        def calculate
        end
      end
      let(:fake_calculator) { FakeCalculator.new }

      it "calculates each discount" do
        expect(c)
          .to receive(:calculator_for)
          .with(discount)
          .and_return(fake_calculator)
        expect(fake_calculator).to receive(:calculate)

        c.calculate
      end

      it "filters mutually exclusive discounts" do
        allow(c).to receive(:calculator_for).and_return(fake_calculator)
        expect(c).to receive(:filter_mutually_exclusive_discounts)
        c.calculate
      end
    end

    describe "#apply_changes_to_basket" do
      it "deletes existing rewards in the basket" do
        basket = instance_double(Basket)
        calculator = Calculator.new([], basket)
        expect(basket).to receive(:delete_rewards)
        calculator.apply_changes_to_basket
      end

      it "calls #apply_changes_to_basket for each of its discount_line calculators" do
        dl_calculator = instance_double(Calculators::FreeProducts)
        discount_line = DiscountLine.new(nil, calculator: dl_calculator)
        calculator = Calculator.new([], Basket.new)
        calculator.discount_lines = [discount_line]
        expect(dl_calculator).to receive(:apply_changes_to_basket)
        calculator.apply_changes_to_basket
      end
    end

    describe "#calculator_for" do
      let(:c) { Calculator.new([Discount.new], Basket.new) }
      subject { c.calculator_for(Discount.new(reward_type: reward_type)) }
      context "reward_type percentage_off_order" do
        let(:reward_type) { "percentage_off_order" }
        it { should be_instance_of Calculators::PercentageOffOrder }
      end
    end

    describe "#discount_lines" do
      let(:c) { Calculator.new([Discount.new], Basket.new) }
      subject { c.discount_lines }

      it { should be_kind_of Array }
    end

    describe "#filter_mutually_exclusive_discounts" do
      let(:c) { Calculator.new([Discount.new], Basket.new) }

      it "removes mutually exclusive discounts, keeping the most favorable " \
      "to the customer" do
        d1 = DiscountLine.new(nil, price_adjustment: -10)
        d2 = DiscountLine.new(
          nil,
          price_adjustment: -20,
          mutually_exclusive_with: %i[
            percentage_off_order amount_off_order
          ].to_set
        )
        d3 = DiscountLine.new(
          nil,
          price_adjustment: -30, mutually_exclusive_with: [
            :amount_off_order, :free_products
          ].to_set
        )
        d4 = DiscountLine.new(
          nil,
          price_adjustment: -40, mutually_exclusive_with: [
            :percentage_off_order
          ].to_set
        )
        d5 = DiscountLine.new(
          nil,
          price_adjustment: -50, mutually_exclusive_with: [
            :amount_off_order
          ].to_set
        )
        c.discount_lines = [d1, d2, d3, d4, d5]
        c.filter_mutually_exclusive_discounts
        expect(c.discount_lines).to eq [d1, d4, d5]
      end
    end
  end
end
