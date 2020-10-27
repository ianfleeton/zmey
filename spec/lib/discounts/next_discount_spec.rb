# frozen_string_literal: true

require "rails_helper"

module Discounts
  RSpec.describe NextDiscount do
    let(:next_discount) { NextDiscount.new(basket: basket) }

    describe "#close?" do
      let(:basket) { Basket.new }

      before { allow(next_discount).to receive(:delta).and_return(delta) }

      subject { next_discount.close? }

      context "delta is less than 20" do
        let(:delta) { 19 }

        it { should be_truthy }
      end

      context "delta is more than 20" do
        let(:delta) { 21 }

        it { should be_falsey }
      end

      context "delta is 20" do
        let(:delta) { 20 }

        it { should be_truthy }
      end

      context "delta is nil" do
        let(:delta) { nil }

        it { should be_falsey }
      end
    end

    describe "#delta" do
      let(:basket) { Basket.new }
      let(:discount) { FactoryBot.build(:discount, reward_type: "percentage_off_order", threshold: 150) }

      before { allow_any_instance_of(EffectiveTotal).to receive(:ex_vat).and_return(100) }

      it "finds delta between threshold and total ex VAT" do
        allow(next_discount).to receive(:find).and_return(discount)
        expect(next_discount.delta).to eq 50
      end

      it "returns falsey when no threshold is found" do
        allow(next_discount).to receive(:find).and_return(nil)
        expect(next_discount.delta).to be_falsey
      end
    end

    describe "#find" do
      let(:basket) { Basket.new }

      before do
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 50)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 100)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 200)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 150)
        FactoryBot.create(:discount, reward_type: "amount_off_order", threshold: 150)
      end

      it "returns the first invalid discount for a given basket" do
        allow_any_instance_of(EffectiveTotal).to receive(:ex_vat).and_return(100)
        discount = next_discount.find
        expect(discount.threshold).to eq 150
      end
    end

    describe "potential_ordered_discounts" do
      let(:basket) { Basket.new }

      before do
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 50)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 200)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 220)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 210)
        FactoryBot.create(:discount, reward_type: "amount_off_order", threshold: 150)
      end

      it "returns an array of invalid discounts for that basket, ordered by threshold" do
        allow_any_instance_of(EffectiveTotal).to receive(:ex_vat).and_return(200)
        discounts = next_discount.potential_ordered_discounts

        expect(discounts.length).to eq 2
        expect(discounts.first.threshold).to eq 210
        expect(discounts.second.threshold).to eq 220
      end
    end

    describe "#ordered_discounts" do
      let(:basket) { nil }

      before do
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 200)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 10)
        FactoryBot.create(:discount, reward_type: "percentage_off_order", threshold: 20)
        FactoryBot.create(:discount, reward_type: "amount_off_order")
      end

      it "returns the valid percentage off order discounts available" do
        expect(next_discount.ordered_discounts.count).to eq 3
        expect(next_discount.ordered_discounts.first.reward_type).to eq "percentage_off_order"
      end

      it "sorts the results by ascending threshold" do
        expect(next_discount.ordered_discounts.first.threshold).to eq 10
        expect(next_discount.ordered_discounts.second.threshold).to eq 20
        expect(next_discount.ordered_discounts.third.threshold).to eq 200
      end
    end
  end
end
