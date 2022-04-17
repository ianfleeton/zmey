require "rails_helper"

describe "admin/products/_form" do
  before do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(Website.new)
    end
    assign(:product, FactoryBot.create(:product))
  end

  it_behaves_like "an extra attributes form", "Product"
end
