require "rails_helper"

RSpec.describe Component, type: :model do
  describe "#to_s" do
    it "returns its name" do
      expect(Component.new(name: "Size/Colour").to_s).to eq "Size/Colour"
    end
  end
end
