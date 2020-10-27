require "rails_helper"

RSpec.describe "products/show.html.erb", type: :view do
  include ProductsHelper
  let(:website) { FactoryBot.build(:website) }

  before(:each) do
    assign(:product, FactoryBot.build(:product))
    assign(:w, website)
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
      allow(view).to receive(:admin?).and_return(false)
    end
  end

  it "renders attributes in <p>" do
    render
  end
end
