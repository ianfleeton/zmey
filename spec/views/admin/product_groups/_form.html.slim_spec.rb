require 'rails_helper'

RSpec.describe 'admin/product_groups/_form.html.slim', type: :view do
  let(:product_group) { ProductGroup.new }

  before do
    assign(:product_group, product_group)
  end

  it 'renders' do
    render
  end
end
