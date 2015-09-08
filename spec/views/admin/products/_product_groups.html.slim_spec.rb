require 'rails_helper'

RSpec.describe 'admin/products/_product_groups.html.slim', type: :view do
  let(:product) { FactoryGirl.create(:product) }
  let(:product_group_placement) { ProductGroupPlacement.new(product: product) }

  before { assign(:product, product) }
  before { assign(:product_group_placement, product_group_placement) }

  it 'renders' do
    render
  end
end
