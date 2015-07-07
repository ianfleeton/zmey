require 'rails_helper'

describe 'products/show.html.erb' do
  include ProductsHelper
  let(:website) { FactoryGirl.build(:website) }

  before(:each) do
    assign(:product, FactoryGirl.build(:product))
    assign(:w, website)
    allow(view).to receive(:website).and_return(website)
    allow(view).to receive(:admin_or_manager?).and_return(:false)
  end

  it "renders attributes in <p>" do
    render
  end
end
