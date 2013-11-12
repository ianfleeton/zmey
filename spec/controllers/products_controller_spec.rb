require 'spec_helper'
require 'shared_examples_for_controllers'

describe ProductsController do
  let(:website) { mock_model(Website).as_null_object }

  def mock_product(stubs={})
    @mock_product ||= mock_model(Product, stubs)
  end

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
    website.stub(:vat_number).and_return('')
  end

  describe "GET show" do
    it "assigns the requested product as @product" do
      website.stub(:name).and_return('Website')
      find_requested_product(page_title: '', name: '', meta_description: '')
      get :show, id: '37'
      expect(assigns[:product]).to equal(mock_product)
    end
  end

  def find_requested_product(stubs={})
    Product.should_receive(:find_by).with(id: '37', website_id: website.id).and_return(mock_product(stubs))
  end
end
