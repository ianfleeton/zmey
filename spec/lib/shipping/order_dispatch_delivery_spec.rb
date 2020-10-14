# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe OrderDispatchDelivery do
    describe "#valid?" do
      let(:dispatch) { nil }
      let(:delivery) { nil }
      let(:order) do
        FactoryBot.create(
          :order,
          dispatch_date: dispatch, delivery_date: delivery,
          shipping_method: "Mainland"
        )
      end
      let(:time) { Time.new(2017, 7, 10, 10, 0) }

      subject { OrderDispatchDelivery.new(order, time: time, cutoff: 10).valid? }

      context "when order has a shipping class with choose_date = true" do
        before do
          FactoryBot.create(
            :shipping_class, name: "Mainland", choose_date: true
          )
        end

        context "when dispatch date missing" do
          let(:dispatch) { nil }
          it { should be_falsey }
        end

        context "when dispatch date invalid" do
          let(:dispatch) { time.to_date }
          it { should be_falsey }
        end

        context "when delivery date invalid" do
          let(:delivery) { time.to_date }
          it { should be_falsey }
        end

        context "when dispatch and delivery dates both valid" do
          let(:dispatch) { Date.new(2017, 7, 12) }
          let(:delivery) { Date.new(2017, 7, 13) }
          it { should be_truthy }
        end

        context "when dispatch and delivery dates both valid, but " \
        "inconsistent with one another" do
          let(:dispatch) { Date.new(2017, 7, 14) }
          let(:delivery) { Date.new(2017, 7, 13) }
          it { should be_falsey }
        end
      end

      context "when order has a shipping class with choose_date = false" do
        before do
          FactoryBot.create(
            :shipping_class, name: "Mainland", choose_date: false
          )
        end

        context "when dispatch date missing" do
          let(:dispatch) { nil }
          it { should be_truthy }
        end
      end
    end

    describe "#delivery_dates" do
      it "returns an array of delivery dates from DispatchDeliveryDate" do
        ddd1 = DispatchDeliveryDate.new(
          Date.new(2017, 7, 10), Date.new(2017, 7, 11)
        )
        ddd2 = DispatchDeliveryDate.new(
          Date.new(2017, 7, 13), Date.new(2017, 7, 14)
        )
        dd_dates = [ddd1, ddd2]
        allow(DispatchDeliveryDate).to receive(:list).and_return dd_dates
        odd = OrderDispatchDelivery.new(Order.new, cutoff: 10)
        expect(odd.delivery_dates).to eq [
          Date.new(2017, 7, 11), Date.new(2017, 7, 14)
        ]
      end
    end

    describe "#use_first_possible_delivery_date" do
      let!(:ship_class) do
        FactoryBot.create(
          :shipping_class, name: "Mainland", choose_date: true
        )
      end
      let(:order) do
        FactoryBot.create(
          :order,
          shipping_method: "Mainland"
        )
      end
      let(:time) { Time.new(2017, 7, 10, 10, 0) }
      let(:odd) { OrderDispatchDelivery.new(order, time: time, cutoff: 10) }

      before do
        odd.use_first_possible_delivery_date
      end

      it "sets and saves the delivery date" do
        expect(order.reload.delivery_date).to eq Date.new(2017, 7, 12)
      end

      it "sets and saves the dispatch date" do
        expect(order.reload.dispatch_date).to eq Date.new(2017, 7, 11)
      end
    end

    describe "#delivery_date=" do
      let!(:ship_class) do
        FactoryBot.create(
          :shipping_class, name: "Mainland", choose_date: true
        )
      end
      let(:order) do
        FactoryBot.create(
          :order,
          shipping_method: "Mainland"
        )
      end
      let(:time) { Time.new(2017, 7, 10, 10, 0) }
      let(:odd) { OrderDispatchDelivery.new(order, time: time, cutoff: 10) }

      context "when delivery date is valid" do
        before do
          odd.delivery_date = "2017-07-12"
        end

        it "sets and saves the delivery date" do
          expect(order.reload.delivery_date).to eq Date.new(2017, 7, 12)
        end

        it "sets and saves the dispatch date" do
          expect(order.reload.dispatch_date).to eq Date.new(2017, 7, 11)
        end
      end

      context "when delivery date is invalid" do
        before do
          odd.delivery_date = "2017-07-10"
        end

        it "leaves the delivery date untouched" do
          expect(order.reload.delivery_date).to be_nil
        end

        it "leaves the dispatch date untouched" do
          expect(order.reload.dispatch_date).to be_nil
        end
      end
    end

    describe "#needs_delivery_date?" do
      before do
        FactoryBot.create(
          :shipping_class, name: "Collection", choose_date: true
        )
      end
      let(:order) do
        instance_double(
          Order,
          fully_shipped?: fully_shipped?,
          basket: Basket.new,
          shipping_method: "Collection"
        )
      end
      subject { OrderDispatchDelivery.new(order, cutoff: 10).needs_delivery_date? }

      context "when order is fully shipped" do
        let(:fully_shipped?) { true }
        it { should be_falsey }
      end

      context "when order is not fully shipped" do
        let(:fully_shipped?) { false }
        it { should be_truthy }
      end
    end

    describe "#dispatch_date" do
      it "returns a dispatch date to match the order's relevant delivery " \
      "date" do
        o = instance_double(
          Order,
          lead_time: 0,
          order_lines: [],
          relevant_delivery_date: Date.new(2017, 7, 31),
          shipping_method: ""
        )
        odd = OrderDispatchDelivery.new(o, cutoff: 10)
        expect(odd.dispatch_date).to eq Date.new(2017, 7, 28)
      end

      it "returns nil when the order has no relevant_delivery_date" do
        o = instance_double(
          Order,
          relevant_delivery_date: nil,
          basket: nil,
          shipping_method: ""
        )
        odd = OrderDispatchDelivery.new(o, cutoff: 10)
        expect(odd.dispatch_date).to be_nil
      end
    end

    describe "#spec" do
      it "returns a spec with the cutoff_hour set to cutoff" do
        odd = OrderDispatchDelivery.new(Order.new, cutoff: 15)
        expect(odd.spec.cutoff_hour).to eq 15
      end
    end
  end
end
