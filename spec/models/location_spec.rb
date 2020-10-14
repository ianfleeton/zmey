# frozen_string_literal: true

require "rails_helper"

RSpec.describe Location, type: :model do
  describe "associations" do
    it { should have_many(:location_orders_exceeded_entries).dependent(:delete_all) }
  end

  describe "validations" do
    subject { FactoryBot.build(:location) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
  end

  describe "#orders_dispatching_on" do
    it "returns the number of orders dispatching on the given date" do
      date = Date.current
      o1 = instance_double(Order)
      o2 = instance_double(Order)
      ds = instance_double(Orders::DueStatus, due_orders: [o1, o2])
      allow(ds)
        .to receive(:departments).with(o1).and_return ["Books", "Electronics"]
      allow(ds)
        .to receive(:departments).with(o2).and_return ["Electronics", "Computers"]

      allow(Orders::DueStatus).to receive(:new).with(today: date).and_return(ds)

      expect(Location.new(name: "Computers").orders_dispatching_on(date)).to eq 1
      expect(Location.new(name: "Electronics").orders_dispatching_on(date)).to eq 2
    end
  end

  describe "#order_limit_reached?" do
    let(:date) { Date.current }

    before do
      o1 = instance_double(Order)
      o2 = instance_double(Order)
      ds = instance_double(Orders::DueStatus, due_orders: [o1, o2])
      allow(ds)
        .to receive(:departments).with(o1).and_return ["Books", "Electronics"]
      allow(ds)
        .to receive(:departments).with(o2).and_return ["Electronics", "Computers"]

      allow(Orders::DueStatus).to receive(:new).with(today: date).and_return(ds)
    end

    it "returns falsey if max_daily_orders is zero" do
      expect(Location.new(name: "Books", max_daily_orders: 0).order_limit_reached?(date)).to be_falsey
    end

    it "returns falsey if dispatching orders is less than max_daily_orders" do
      expect(Location.new(name: "Books", max_daily_orders: 2).order_limit_reached?(date)).to be_falsey
    end

    it "returns falsey if dispatching orders is gte to max_daily_orders" do
      expect(Location.new(name: "Books", max_daily_orders: 1).order_limit_reached?(date)).to be_truthy
    end
  end
end
