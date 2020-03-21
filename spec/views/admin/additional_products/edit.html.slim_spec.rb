require "rails_helper"

describe "admin/additional_products/edit.html.slim" do
  let(:abacus) { FactoryBot.create(:product) }
  let(:beads) { FactoryBot.create(:product) }
  let(:additional_product) { AdditionalProduct.create!(product: abacus, additional_product: beads) }

  before do
    assign(:additional_product, additional_product)
  end

  it "renders" do
    render
  end
end
