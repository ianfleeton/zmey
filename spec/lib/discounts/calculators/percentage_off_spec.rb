# frozen_string_literal: true

require "rails_helper"

module Discounts
  module Calculators
    RSpec.describe PercentageOff do
      describe "#calculate" do
        let(:discount_lines) { [] }
        let(:product) do
          instance_double(Product)
        end
        let(:item) do
          instance_double(BasketItem, product: product, name: "Filgu")
        end
        let(:basket) { instance_double(Basket, basket_items: [item]) }
        let(:context) do
          Calculator.new([], basket)
        end
        let(:discount) do
          instance_double(
            Discount,
            name: "5% off Zomlings",
            reward_amount: 5,
            product_group: discount_group
          )
        end
        let(:calc) { PercentageOff.new(context, discount) }
        before do
          allow(item).to receive(:line_total).with(false).and_return(10)
          allow(item).to receive(:vat_amount).and_return(2)
          calc.calculate
        end

        shared_examples_for "a discount applier" do
          let(:dl) { calc.discount_lines.first }

          it "applies a discount" do
            expect(calc.discount_lines.count).to eq 1
          end

          it "sets the discount name" do
            expect(dl.name).to eq "5% off Zomlings - Filgu"
          end

          it "sets the price adjustment" do
            expect(dl.price_adjustment).to eq(-0.50)
          end

          it "sets the tax adjustment" do
            expect(dl.tax_adjustment).to eq(-0.10)
          end

          it "is mutually exclusive with :percentage_off_order" do
            expect(dl.mutually_exclusive_with.member?(:percentage_off_order)).to be_truthy
          end
        end

        shared_examples_for "a multiple discount applier" do
          let(:dl) { calc.discount_lines.first }
          let(:item2) { instance_double(BasketItem, product: product, name: "Brum", line_total: 15, vat_amount: 3) }
          let(:basket) { instance_double(Basket, basket_items: [item, item2]) }

          it "applies a discount" do
            expect(calc.discount_lines.count).to eq 1
          end

          it "sets the discount name" do
            expect(dl.name).to eq "5% off Zomlings - Filgu, Brum"
          end

          it "sets the price adjustment" do
            expect(dl.price_adjustment).to eq(-1.25)
          end

          it "sets the tax adjustment" do
            expect(dl.tax_adjustment).to eq(-0.25)
          end
        end

        context "discount has no product group" do
          let(:discount_group) { nil }
          it_behaves_like "a discount applier"
          it_behaves_like "a multiple discount applier"
        end

        context "discount has same product group" do
          let(:discount_group) do
            instance_double(ProductGroup, products: [product])
          end
          it_behaves_like "a discount applier"
          it_behaves_like "a multiple discount applier"
        end

        context "discount has a different product group" do
          let(:discount_group) { instance_double(ProductGroup, products: []) }
          it "does not add a discount" do
            expect(calc.discount_lines.length).to eq 0
          end
        end
      end
    end
  end
end
