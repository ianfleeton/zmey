require 'rails_helper'

RSpec.describe 'admin/product_groups/edit.html.slim', type: :view do
  let(:product_group) { FactoryGirl.create(:product_group) }
  let(:product_group_placement) { ProductGroupPlacement.new }

  before do
    assign(:product_group, product_group)
    assign(:product_group_placement, product_group_placement)
  end

  it 'renders' do
    render
  end

  context 'with products' do
    let!(:product) { FactoryGirl.create(:product) }

    it 'renders' do
      render
    end
  end
end
