require 'rails_helper'

describe 'admin/products/_form.html.slim' do
  before do
    allow(view).to receive(:website).and_return(Website.new)
    assign(:product, FactoryBot.create(:product))
  end

  it_behaves_like 'an extra attributes form', 'Product'
end
