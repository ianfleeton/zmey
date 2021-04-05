# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe ShippingCalculator do
    let(:basket) { FactoryBot.create(:basket) }
    let(:shipping_class) { nil }
    let(:amount_for) { 23.45 }
    let(:delivery_date) { Date.new(2020, 8, 17) }
    let(:options) do
      {
        basket: basket,
        shipping_class: shipping_class,
        delivery_date: delivery_date
      }
    end

    before do
      if shipping_class
        allow(shipping_class).to receive(:amount_for).with(basket, delivery_date)
          .and_return amount_for
      end
    end

    describe "#amount" do
      subject { ShippingCalculator.new(options).amount }

      context "with shipping class" do
        let(:shipping_class) { FactoryBot.create(:shipping_class) }
        it { should eq amount_for }
      end

      context "without shipping class" do
        it { should eq 0 }
      end
    end

    describe "#vat_amount" do
      let(:calculator) { ShippingCalculator.new(options) }
      let(:shipping_class) do
        instance_double(ShippingClass, charge_vat?: charge_vat)
      end

      subject { calculator.vat_amount }

      context "when shipping class charges tax" do
        let(:charge_vat) { true }
        it { should eq 4.69 }
      end

      context "when shipping class does not charge tax" do
        let(:charge_vat) { false }
        it { should be_zero }
      end
    end

    describe "#quote_needed?" do
      let(:basket) { instance_double(Basket) }

      context "when basket overweight" do
        let(:shipping_class) do
          instance_double(
            ShippingClass, max_product_weight: 10, shipping_table_rows: []
          )
        end
        before do
          expect(basket)
            .to receive(:overweight?)
            .with(max_product_weight: 10)
            .and_return(true)
        end

        it "returns truthy" do
          calc = ShippingCalculator.new(
            basket: basket, shipping_class: shipping_class
          )
          expect(calc.quote_needed?).to be_truthy
        end
      end

      context "when basket not overweight?" do
        before do
          allow(basket).to receive(:overweight?).and_return(false)
        end

        it "returns falsey when there's no shipping class specified" do
          expect(ShippingCalculator.new(basket: basket).quote_needed?)
            .to be_falsey
        end

        it "returns falsey when the specified shipping class has some table " \
        "rows" do
          sc = FactoryBot.create(:shipping_class)
          ShippingTableRow.create!(shipping_class: sc)
          calc = ShippingCalculator.new({shipping_class: sc, basket: basket})
          expect(calc.quote_needed?).to be_falsey
        end

        it "returns truthy when the specified shipping class has no table rows" do
          sc = FactoryBot.create(:shipping_class)
          calc = ShippingCalculator.new({shipping_class: sc, basket: basket})
          expect(calc.quote_needed?).to be_truthy
        end
      end
    end
  end
end
