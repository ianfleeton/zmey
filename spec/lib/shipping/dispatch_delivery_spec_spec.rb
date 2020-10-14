require "rails_helper"

module Shipping
  RSpec.describe DispatchDeliverySpec do
    describe ".new" do
      it "sets up a products dispatch date checker" do
        p1 = Product.new
        p2 = Product.new
        line1 = instance_double(OrderLine, product: p1, delivery_cutoff_hour: 9)
        line2 = instance_double(OrderLine, product: p1, delivery_cutoff_hour: 9)
        line3 = instance_double(OrderLine, product: p2, delivery_cutoff_hour: 9)
        items = [line1, line2, line3]

        checker = instance_double(ProductsDispatchDateChecker)

        expect(ProductsDispatchDateChecker)
          .to receive(:new)
          .with([p1, p2])
          .and_return(checker)

        spec = DispatchDeliverySpec.new(
          start: nil, lead: nil, delivery: nil, cutoff: nil, num: nil,
          items: items
        )

        expect(spec.dispatch_date_checker).to eq checker
      end

      it "sets cutoff_hour to the given cutoff" do
        spec = DispatchDeliverySpec.new(
          start: nil, lead: nil, delivery: nil, cutoff: 11, num: nil, items: []
        )
        expect(spec.cutoff_hour).to eq 11
      end

      it "sets cutoff_hour to the earliest hour for given items" do
        items = [
          instance_double(BasketItem, delivery_cutoff_hour: 10, product: nil),
          instance_double(BasketItem, delivery_cutoff_hour: 9, product: nil)
        ]
        spec = DispatchDeliverySpec.new(
          start: nil, lead: nil, delivery: nil, cutoff: 11, num: nil,
          items: items
        )
        expect(spec.cutoff_hour).to eq 9
      end
    end

    describe ".default" do
      let(:collection) { instance_double(ShippingClass, collection?: true) }

      it "returns an instance of DispatchDeliverySpec" do
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: ShippingClass.new, cutoff: 10
        )
        expect(spec)
          .to be_instance_of(DispatchDeliverySpec)
      end

      it "sets the lead time from the lead_time parameter" do
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 3, shipping_class: ShippingClass.new, cutoff: 10
        )
        expect(spec.lead_time).to eq 3
      end

      it "sets up a products dispatch date checker from the basket's items" do
        p1 = Product.new
        p2 = Product.new
        item1 = instance_double(
          BasketItem, product: p1, delivery_cutoff_hour: 10
        )
        item2 = instance_double(
          BasketItem, product: p2, delivery_cutoff_hour: 10
        )

        items = [item1, item2]

        checker = instance_double(ProductsDispatchDateChecker)

        expect(ProductsDispatchDateChecker)
          .to receive(:new)
          .with([p1, p2])
          .and_return(checker)

        spec = DispatchDeliverySpec.default(
          items: items, lead_time: 10, shipping_class: collection, cutoff: 10
        )

        expect(spec.dispatch_date_checker).to eq checker
      end

      it "sets the lead time to 0 when collection" do
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: collection, cutoff: 10
        )
        expect(spec.lead_time).to eq 0
      end

      it "sets delivery_time to 0 for collection" do
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: collection, cutoff: 10
        )
        expect(spec.delivery_time).to eq 0
      end

      it "sets delivery_time to 1 for non-collection" do
        mainland = instance_double(ShippingClass, collection?: false)
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: mainland, cutoff: 10
        )
        expect(spec.delivery_time).to eq 1
      end

      it "sets delivery_time to 1 for nil shipping class" do
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: nil, cutoff: 10
        )
        expect(spec.delivery_time).to eq 1
      end

      it "sets the cutoff_hour from the given cutoff param" do
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: nil, cutoff: 10
        )
        expect(spec.cutoff_hour).to eq 10
      end

      it "sets the cutoff_hour to 24 for collection" do
        collection = instance_double(ShippingClass, collection?: true)
        spec = DispatchDeliverySpec.default(
          items: [], lead_time: 0, shipping_class: collection, cutoff: 10
        )
        expect(spec.cutoff_hour).to eq 24
      end
    end
  end
end
