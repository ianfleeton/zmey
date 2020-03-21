require "rails_helper"

RSpec.describe QuantityPrice, type: :model do
  describe "#to_s" do
    it "returns a string containing quantity and price" do
      qp = QuantityPrice.new(quantity: 5, price: 10.0)
      expect(qp.to_s).to eq "5 @ 10.0"
    end
  end
end
