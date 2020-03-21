require "rails_helper"

RSpec.describe Permutation, type: :model do
  describe "#to_s" do
    it "returns the permutation attribute" do
      expect(Permutation.new(permutation: "_1__2_").to_s).to eq "_1__2_"
    end
  end
end
