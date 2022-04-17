require "rails_helper"

RSpec.describe "admin/additional_products/new", type: :view do
  let(:abacus) { FactoryBot.create(:product) }
  let(:additional_product) { AdditionalProduct.new(product: abacus) }

  before do
    assign(:additional_product, additional_product)
  end

  it "renders" do
    render
  end
end
