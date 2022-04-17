require "rails_helper"

RSpec.describe "admin/discounts/_form", type: :view do
  let(:discount) { Discount.new }

  before do
    assign(:discount, discount)
  end

  it "renders" do
    render
  end
end
