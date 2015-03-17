require 'rails_helper'

describe 'admin/additional_products/new.html.slim' do
  let(:abacus) { FactoryGirl.create(:product) }
  let(:additional_product) { AdditionalProduct.new(product: abacus) }

  before do
    assign(:additional_product, additional_product)
  end

  it 'renders' do
    render
  end
end
