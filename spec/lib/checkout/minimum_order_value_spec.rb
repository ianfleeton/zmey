require "rails_helper"

RSpec.describe Checkout::MinimumOrderValue do
  def shopping(total)
    instance_double(Basket, total_for_shipping: BigDecimal(total.to_s))
  end

  it "is below the minimum for goods worth less than £2" do
    expect(described_class.below?(shopping(1.99))).to be true
  end

  it "allows goods worth exactly £2" do
    expect(described_class.below?(shopping(2))).to be false
  end

  it "allows free orders" do
    expect(described_class.below?(shopping(0))).to be false
  end

  it "explains the minimum" do
    expect(described_class.message).to include("£2.00")
  end
end
