require "rails_helper"

RSpec.describe PreferredDeliveryDateSettings, type: :model do
  describe "#valid_date?" do
    it "returns true only if the date is included in #dates" do
      pdds = PreferredDeliveryDateSettings.new
      allow(pdds).to receive(:dates).and_return([Date.new(2015, 5, 5)])
      expect(pdds.valid_date?(Date.new(2015, 5, 5))).to eq true
      expect(pdds.valid_date?(Date.new(2015, 5, 6))).to eq false
    end
  end
end
