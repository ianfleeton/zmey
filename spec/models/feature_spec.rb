require "rails_helper"

RSpec.describe Feature, type: :model do
  describe "#to_s" do
    it "returns its name" do
      expect(Feature.new(name: "Colour").to_s).to eq "Colour"
    end
  end
end
