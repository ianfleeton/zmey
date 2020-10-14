require "rails_helper"

RSpec.describe ProductGroup, type: :model do
  describe "associations" do
    it { should belong_to(:location).optional }
  end

  describe "delegated methods" do
    it { should delegate_method(:name).to(:location).with_prefix.allow_nil }
  end

  describe "#to_s" do
    it "returns name" do
      expect(ProductGroup.new(name: "BOGOF").to_s).to eq "BOGOF"
    end
  end
end
