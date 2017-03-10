require 'rails_helper'

RSpec.describe Admin::PaymentsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'POST create' do
    let(:order) { FactoryGirl.create(:order) }

    context 'when successful' do
      it 'creates a new Payment' do
        expect { post_create }.to change { Payment.count }.by 1
      end

      it 'sets the payment as accepted' do
        post_create
        expect(Payment.last.accepted).to eq true
      end

      it 'redirects to edit order' do
        post_create
        expect(response).to redirect_to edit_admin_order_path(order)
      end
    end

    def post_create
      post :create, params: { payment: {service_provider: 'Cheque', amount: '10', order_id: order.id} }
    end
  end
end
