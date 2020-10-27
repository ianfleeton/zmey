# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe ShippingClassFinder do
    let(:basket_match) { Shipping::ShippingClassShoppingMatch }
    let(:shipping_class) { FactoryBot.create(:shipping_class) }
    let(:delivery_address) { FactoryBot.create(:address) }

    describe "#find" do
      context "when shipping_class_id is present and the basket is valid for " \
      "it" do
        it " returns the corresponding shipping class" do
          allow_any_instance_of(basket_match).to receive(:valid?)
            .and_return(true)
          scf = ShippingClassFinder.new(
            shipping_class_id: shipping_class.id,
            default_shipping_class: nil,
            delivery_address: nil,
            basket: Basket.new
          )
          expect(scf.find).to eq shipping_class
        end
      end

      context "when shipping_class_id is not present" do
        it "returns the best shipping class valid for the delivery address" do
          basket = instance_double(Basket)
          sc1 = instance_double(ShippingClass)
          sc2 = instance_double(ShippingClass)
          validator = instance_double(basket_match, valid?: false)
          allow(basket_match).to receive(:new).with(nil, basket).and_return(validator)
          allow(delivery_address).to receive(:shipping_classes)
            .and_return [sc1, sc2]

          scf = ShippingClassFinder.new(
            shipping_class_id: nil,
            default_shipping_class: nil,
            delivery_address: delivery_address,
            basket: basket
          )
          # Stub included module method that is tested separately.
          expect(scf).to receive(:best_shipping_class).with([sc1, sc2], basket).and_return sc2
          expect(scf.find).to eq sc2
        end
      end
    end
  end
end
