# frozen_string_literal: true

require "rails_helper"

module Discounts
  module Calculators
    RSpec.describe AmountOffOrder do
      describe "#calculate" do
        let(:discount_lines) { [] }
        let(:basket) do
          instance_double(Basket, basket_items: [])
        end
        let(:context) { Calculator.new([], basket) }
        let(:discount) do
          Discount.new(name: "£25 off order", threshold: 500, reward_amount: 25)
        end
        let(:calc) { AmountOffOrder.new(context, discount) }
        before do
          ef = instance_double(EffectiveTotal, ex_vat: ex_vat, vat_rate: 1.2)
          allow(EffectiveTotal)
            .to receive(:new)
            .with(discount, basket)
            .and_return(ef)
          calc.calculate
        end

        context "when effective ex_vat below threshold" do
          let(:ex_vat) { 499.99 }
          it "does not add a discount" do
            expect(calc.discount_lines.length).to eq 0
          end
        end

        context "when effective ex_vat meets threshold" do
          let(:ex_vat) { 500.00 }
          let(:dl) { calc.discount_lines.first }

          it "adds a discount" do
            expect(calc.discount_lines.length).to eq 1
          end

          it "sets the discount name" do
            expect(dl.name).to eq "£25 off order"
          end

          it "sets the price adjustment, rounded, with VAT removed" do
            expect(dl.price_adjustment).to eq(-20.83)
          end

          it "sets the VAT adjustment, rounded" do
            expect(dl.tax_adjustment).to eq(-4.17)
          end
        end
      end
    end
  end
end
