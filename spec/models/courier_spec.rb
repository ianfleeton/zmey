require "rails_helper"

RSpec.describe Courier, type: :model do
  describe "associations" do
    it { should have_many(:shipments).dependent(:restrict_with_error) }
  end

  describe "validations" do
    subject { FactoryBot.build(:courier) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_presence_of(:name) }
  end

  describe ".collection" do
    it "returns an existing courier named collection" do
      collection = Courier.create!(name: Courier::COLLECTION)
      expect(Courier.collection).to eq collection
    end

    it "creates a courier called collection" do
      expect(Courier.collection.name).to eq Courier::COLLECTION
    end
  end

  describe "#to_s" do
    it "returns its name" do
      expect(Courier.new(name: "Royal Mail").to_s).to eq "Royal Mail"
    end
  end

  describe "#generate_tracking_url" do
    subject do
      Courier
        .new(tracking_url: tracking_url)
        .generate_tracking_url(consignment: "CONS123", postcode: "POST CODE", order_number: "10001")
    end

    context "when tracking_url present" do
      let(:tracking_url) { "https://rm.example.com/{{consignment}}/{{postcode}}" }
      it { should eq "https://rm.example.com/CONS123/POSTCODE" }
    end

    context "with order_number and no consignment" do
      let(:tracking_url) { "https://rm.example.com/{{order_number}}/{{postcode}}" }
      it { should eq "https://rm.example.com/10001/POSTCODE" }
    end

    context "when tracking_url blank" do
      let(:tracking_url) { nil }
      it { should be_nil }
    end
  end
end
