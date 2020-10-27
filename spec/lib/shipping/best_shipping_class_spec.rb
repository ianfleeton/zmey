# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe BestShippingClass do
    class DummyClass
      include BestShippingClass
    end

    describe "#best_shipping_class" do
      it "returns only valid shipping classes" do
        basket = instance_double(Basket)
        sc1 = instance_double(ShippingClass, amount_for: 5)
        sc2 = instance_double(ShippingClass, amount_for: 5)
        shipping_classes = [sc1, sc2]
        validator1 = instance_double(Shipping::ShippingClassShoppingMatch, valid?: false)
        validator2 = instance_double(Shipping::ShippingClassShoppingMatch, valid?: true)
        allow(Shipping::ShippingClassShoppingMatch).to receive(:new).with(sc1, basket).and_return validator1
        allow(Shipping::ShippingClassShoppingMatch).to receive(:new).with(sc2, basket).and_return validator2

        dc = DummyClass.new
        expect(dc.best_shipping_class(shipping_classes, basket)).to eq sc2
      end

      it "returns the cheapest shipping class for the customer" do
        basket = instance_double(Basket)
        sc1 = instance_double(ShippingClass, amount_for: 5)
        sc2 = instance_double(ShippingClass, amount_for: 3)
        shipping_classes = [sc1, sc2]
        validator = instance_double(Shipping::ShippingClassShoppingMatch, valid?: true)
        allow(Shipping::ShippingClassShoppingMatch).to receive(:new).with(sc1, basket).and_return validator
        allow(Shipping::ShippingClassShoppingMatch).to receive(:new).with(sc2, basket).and_return validator

        dc = DummyClass.new
        expect(dc.best_shipping_class(shipping_classes, basket)).to eq sc2
      end
    end
  end
end
