# frozen_string_literal: true

require "rails_helper"

RSpec.describe ShippingClass, type: :model do
  it do
    should have_many(:shipping_zones)
      .with_foreign_key("default_shipping_class_id")
  end
  it do
    should have_many(:websites).with_foreign_key("default_shipping_class_id")
  end

  shared_examples_for "a shipping class by name finder" do |name|
    it "returns the shipping class named '#{name}'" do
      match = FactoryBot.create(
        :shipping_class, name: name
      )
      FactoryBot.create(
        :shipping_class, name: "not the one"
      )
      expect(subject).to eq match
    end
  end

  describe ".collection" do
    subject { ShippingClass.collection }
    it_behaves_like "a shipping class by name finder", ShippingClass::COLLECTION
  end

  describe "#collection?" do
    subject { sc.collection? }
    context "when the shipping class is named Collection" do
      let(:sc) { ShippingClass.new(name: ShippingClass::COLLECTION) }
      it { should be_truthy }
    end
    context "when the shipping class is named something else" do
      let(:sc) { ShippingClass.new(name: "Mainland UK") }
      it { should be_falsey }
    end
  end

  describe "#amount_for" do
    let(:shipping_class) do
      FactoryBot.create(:shipping_class, table_rate_method: table_rate_method)
    end
    let(:total) { 0 }
    let(:weight) { 0 }
    let(:basket) { FactoryBot.create(:basket) }

    subject { shipping_class.amount_for(basket) }

    before do
      ShippingTableRow.create!(
        shipping_class: shipping_class, trigger_value: 0, amount: 5
      )
      ShippingTableRow.create!(
        shipping_class: shipping_class, trigger_value: 10, amount: 15
      )
      ShippingTableRow.create!(
        shipping_class: shipping_class, trigger_value: 20, amount: 25
      )
      ShippingTableRow.create!(
        shipping_class: shipping_class, trigger_value: 30, amount: 35
      )
      allow(basket).to receive(:total_for_shipping).and_return(total)
      allow(basket).to receive(:weight).and_return(weight)
    end

    context "by basket total" do
      let(:table_rate_method) { "basket_total" }

      context "total is 3" do
        let(:total) { 3 }
        it { should eq 5 }
      end

      context "total is 23" do
        let(:total) { 23 }
        it { should eq 25 }
      end
    end

    context "by weight" do
      let(:table_rate_method) { "weight" }

      context "weight is 13" do
        let(:weight) { 13 }
        it { should eq 15 }
      end

      context "weight is 33" do
        let(:weight) { 33 }
        it { should eq 35 }
      end
    end

    context "shipping class has no table rows" do
      let(:table_rate_method) { "basket_total" }
      subject { FactoryBot.create(:shipping_class).amount_for(basket) }
      it { should eq 0 }
    end
  end

  describe "#to_s" do
    it "returns its name" do
      expect(ShippingClass.new(name: "First Class").to_s).to eq "First Class"
    end
  end
end
