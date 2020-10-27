# frozen_string_literal: true

require "rails_helper"

module Discounts
  module Calculators
    RSpec.describe Base do
      subject { Base.new(nil, nil) }
      it { should respond_to :basket }
      it { should respond_to :basket_items }
      it { should respond_to :discount_lines }

      # Delegated methods.
      it { should delegate_method(:add_discount_line).to(:context) }

      describe "#initialize" do
        it "makes the calculator context and discount params readable" do
          ctx = double(Calculator)
          disc = Discount.new
          b = Base.new(ctx, disc)
          expect(b.context).to eq ctx
          expect(b.discount).to eq disc
        end
      end
    end
  end
end
