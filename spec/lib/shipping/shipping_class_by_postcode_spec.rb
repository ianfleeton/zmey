# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe ShippingClassByPostcode do
    describe "#find" do
      let!(:isle_of_man) do
        FactoryBot.create(
          :shipping_class,
          postcode_districts: "IM1"
        )
      end
      let!(:scottish_highlands) do
        FactoryBot.create(
          :shipping_class,
          postcode_districts: "IV3 IV36 KW1"
        )
      end
      let!(:ni_roi) do
        FactoryBot.create(
          :shipping_class,
          postcode_districts:
            'E45 BT1 W12\s([0-9]|A|C|D|E|F|H|K|N|P|R|T|V|W|X){4}'
        )
      end
      before do
        FactoryBot.create(:shipping_class, name: ShippingClass::MAINLAND)
      end

      subject { ShippingClassByPostcode.new(postcode: postcode).find }

      context "with IV3 postcode" do
        let(:postcode) { "IV3 5AB" }
        it { should eq scottish_highlands }
      end

      context "with IV36 postcode" do
        let(:postcode) { "IV36 1AA" }
        it { should eq scottish_highlands }
      end

      context "with unformatted IV36 postcode" do
        let(:postcode) { " iv361aa " }
        it { should eq scottish_highlands }
      end

      context "with IV32 postcode" do
        let(:postcode) { "IV32 7DB" }
        it { should eq ShippingClass.mainland }
      end

      context "with IM1 postcode" do
        let(:postcode) { "IM1 1AD" }
        it { should eq isle_of_man }
      end

      context "with invalid (too-short) postcode" do
        let(:postcode) { "I" }
        it { should eq ShippingClass.mainland }
      end

      context "with nil postcode" do
        let(:postcode) { nil }
        it { should eq ShippingClass.mainland }
      end

      context "with W12 ROI postcode" do
        let(:postcode) { "W12 P584" }
        it { should eq ni_roi }
      end

      context "with W12 London postcode" do
        let(:postcode) { "W12 8LP" }
        it { should eq ShippingClass.mainland }
      end

      # Test no clash with Republic of Ireland E45 postcode.
      context "with DE45 postcode" do
        let(:postcode) { "DE45 1AA" }
        it { should eq ShippingClass.mainland }
      end
    end

    describe "#find_all" do
      let!(:isle_of_man) {
        FactoryBot.create(:shipping_class, postcode_districts: "IM1")
      }
      let!(:scotland_delivery) {
        FactoryBot.create(:shipping_class, postcode_districts: "IV3 IV36")
      }
      let!(:scottish_highlands) {
        FactoryBot.create(:shipping_class, postcode_districts: "IV3 IV36 KW1")
      }
      let!(:ni_roi) {
        FactoryBot.create(
          :shipping_class,
          postcode_districts: 'E45 BT1 W12\s([0-9]|A|C|D|E|F|H|K|N|P|R|T|V|W|X){4}'
        )
      }
      let!(:mainland) { FactoryBot.create(:shipping_class, name: ShippingClass::MAINLAND) }
      let!(:another_mainland) { FactoryBot.create(:shipping_class, name: "Another mainland") }
      let(:subject) { ShippingClassByPostcode.new(postcode: postcode).find_all }

      context "with a Scottish postcode" do
        let(:postcode) { "IV3 5AB" }
        it "should return all ShippingClasses for the postcode" do
          expect(subject).to include(scotland_delivery, scottish_highlands)
          expect(subject).not_to include(isle_of_man, ni_roi, mainland)
        end
      end

      context "with a non-matched mainland postcode" do
        let(:postcode) { "DN1 2QP" }
        it "should return Mainland" do
          expect(subject.length).to eq 1
          expect(subject).to include(mainland)
        end
      end
    end
  end
end
