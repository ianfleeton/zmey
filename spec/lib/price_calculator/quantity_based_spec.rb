require "rails_helper"

module PriceCalculator
  RSpec.describe QuantityBased do
    describe "#price" do
      it "uses Product#price_at_quantity" do
        price_for_4 = 10
        product = Product.new
        allow(product).to receive(:price_at_quantity).with(4).and_return(price_for_4)
        quantity_based = QuantityBased.new(product: product, quantity: 4)
        expect(quantity_based.price).to eq price_for_4
      end
    end
  end
end
