require "rails_helper"

RSpec.describe Administrator, type: :model do
  describe "validations" do
    it { should validate_length_of(:email).is_at_most(191) }
    it { should validate_presence_of(:name) }
  end

  describe "#to_s" do
    it "returns the administrator's name" do
      expect(Administrator.new(name: "Louise").to_s).to eq "Louise"
    end
  end
end
