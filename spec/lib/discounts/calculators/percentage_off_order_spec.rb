require 'rails_helper'

module Discounts
  module Calculators
    RSpec.describe PercentageOffOrder do
      describe '#apply_discount' do
        let(:effective_total) { double(EffectiveTotal, ex_tax: 10, tax_amount: 2) }
        let(:context) { double(Calculator, discount_lines: []) }
        let(:calc) { PercentageOffOrder.new(context, Discount.new) }

        it 'applies discounts mutually exclusive with :percentage_off_order' do
          calc.apply_discount(effective_total)
          expect(calc.discount_lines.first.mutually_exclusive_with.member?(:percentage_off_order)).to be_truthy
        end
      end
    end
  end
end
