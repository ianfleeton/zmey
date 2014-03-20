require 'spec_helper'

describe 'products/google_data_feed.xml.erb' do
  let(:website)  { FactoryGirl.build(:website) }
  let(:products) { [FactoryGirl.create(:product, gender: 'unisex')] }

  before do
    assign(:products, products)
    view.stub(:website).and_return(website)
  end

  it 'includes gender' do
    render

    expect(rendered).to include('<g:gender>unisex</g:gender>')
  end
end
