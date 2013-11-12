require 'spec_helper'

describe BasketController do
  let(:website) { mock_model(Website, {name: 'www', email: 'anon@example.org'}).as_null_object }
  let(:valid_address) { Address.new(email_address: 'anon@example.org', address_line_1: '123 Street', town_city: 'Harrogate', postcode: 'HG1', country: FactoryGirl.create(:country)) }

  before do
    Website.stub(:for).and_return(website)
    website.stub(:private?).and_return(false)
  end

  describe 'POST place_order' do
    context 'with an address' do
      before do
        controller.stub(:find_delivery_address).and_return(valid_address)
      end

      it 'deletes a previous unpaid order if one exists' do
        controller.should_receive(:delete_previous_unpaid_order_if_any)
        post 'place_order'
      end

      it "records the customer's IP address" do
        post 'place_order'
        expect(assigns(:order).ip_address).to eq '0.0.0.0'
      end
    end
  end
end
