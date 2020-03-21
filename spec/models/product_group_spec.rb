require "rails_helper"

RSpec.describe ProductGroup, type: :model do
  describe "#to_s" do
    it "returns name" do
      expect(ProductGroup.new(name: "BOGOF").to_s).to eq "BOGOF"
    end
  end
end
