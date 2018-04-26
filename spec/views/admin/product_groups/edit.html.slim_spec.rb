require 'rails_helper'

RSpec.describe 'admin/product_groups/edit.html.slim', type: :view do
  let(:product_group) { FactoryBot.create(:product_group) }
  let(:product_group_placement) { ProductGroupPlacement.new }

  before do
    assign(:product_group, product_group)
    assign(:product_group_placement, product_group_placement)
  end

  it 'renders' do
    render
  end

  context 'with products' do
    let!(:product) { FactoryBot.create(:product) }

    it 'renders' do
      render
    end
  end

  context 'with products placed in group' do
    let!(:product) { FactoryBot.create(:product) }
    let!(:placed) { ProductGroupPlacement.create!(product: product, product_group: product_group) }

    it 'renders' do
      render
    end
  end
end
