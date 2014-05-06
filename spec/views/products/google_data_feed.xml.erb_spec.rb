require 'spec_helper'

describe 'products/google_data_feed.xml.erb' do
  let(:website)  { FactoryGirl.build(:website) }
  let(:products) { [FactoryGirl.create(:product, age_group: 'adult', gender: 'unisex')] }

  before do
    assign(:products, products)
    view.stub(:website).and_return(website)
  end

  it 'includes age group' do
    render
    expect(rendered).to include('<g:age_group>adult</g:age_group>')
  end

  it 'includes gender' do
    render
    expect(rendered).to include('<g:gender>unisex</g:gender>')
  end
end
