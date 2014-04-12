require 'spec_helper'

describe BasketController do
  let(:website) { FactoryGirl.create(:website, name: 'www', email: 'anon@example.org') }
  let(:valid_address) { Address.new(email_address: 'anon@example.org', address_line_1: '123 Street', town_city: 'Harrogate', postcode: 'HG1', country: FactoryGirl.create(:country)) }

  before do
    controller.stub(:website).and_return(website)
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
