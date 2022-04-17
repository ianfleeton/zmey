require "rails_helper"

RSpec.describe "admin/shipping_classes/_form", type: :view do
  before do
    assign(:shipping_class, ShippingClass.new)
  end

  it "renders" do
    render
  end
end
