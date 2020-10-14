# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe ProductsDispatchDateChecker do
    describe "#locations" do
      it "returns empty collection for no products" do
        products = []
        checker = ProductsDispatchDateChecker.new(products)
        expect(checker.locations).to be_empty
      end

      it "returns locations for an item" do
        location = instance_double(Location)
        products = [
          instance_double(Product, locations: [location])
        ]

        checker = ProductsDispatchDateChecker.new(products)
        locations = checker.locations

        expect(locations.count).to eq 1
        expect(locations.first).to eq location
      end

      it "returns all locations for an item" do
        l1 = instance_double(Location)
        l2 = instance_double(Location)
        products = [
          instance_double(Product, locations: [l1, l2])
        ]

        checker = ProductsDispatchDateChecker.new(products)
        locations = checker.locations

        expect(locations.count).to eq 2
        expect(locations).to include l1
        expect(locations).to include l2
      end

      it "returns the locations for multiple items" do
        l1 = instance_double(Location)
        l2 = instance_double(Location)
        p1 = instance_double(Product, locations: [l1])
        p2 = instance_double(Product, locations: [l2])
        products = [p1, p2]

        checker = ProductsDispatchDateChecker.new(products)
        locations = checker.locations

        expect(locations.count).to eq 2
        expect(locations).to include l1
        expect(locations).to include l2
      end

      it "only includes each location once" do
        l1 = instance_double(Location)
        p1 = instance_double(Product, locations: [l1])
        p2 = instance_double(Product, locations: [l1])
        products = [p1, p2]

        checker = ProductsDispatchDateChecker.new(products)
        locations = checker.locations

        expect(locations.count).to eq 1
        expect(locations.first).to eq l1
      end
    end

    describe "#possible?" do
      context "with no products" do
        it "returns truthy" do
          products = []
          checker = ProductsDispatchDateChecker.new(products)
          expect(checker.possible?(Date.new)).to be_truthy
        end
      end

      context "with products in locations whose order limit is reached" do
        it "returns falsey" do
          date = Date.current
          location = instance_double(Location, id: 123)
          product = instance_double(Product, locations: [location])
          products = [product]
          allow(LocationOrdersExceededEntry)
            .to receive(:exists?)
            .with(exceeded_on: date, location_id: 123)
            .and_return(true)
          checker = ProductsDispatchDateChecker.new(products)
          expect(checker.possible?(date)).to be_falsey
        end
      end

      context "with products in product groups whose order limit is not reached" do
        it "returns truthy" do
          date = Date.current
          location = instance_double(Location, id: 123)
          product = instance_double(Product, locations: [location])
          products = [product]
          allow(LocationOrdersExceededEntry)
            .to receive(:exists?)
            .with(exceeded_on: date, location_id: 123)
            .and_return(false)
          checker = ProductsDispatchDateChecker.new(products)
          expect(checker.possible?(date)).to be_truthy
        end
      end
    end
  end
end
