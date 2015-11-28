require 'rails_helper'

RSpec.describe Admin::PaymentsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe 'GET new' do
    let(:order) { FactoryGirl.create(:order) }
    let(:outstanding_payment_amount) { 10 }

    before do
      allow_any_instance_of(Order).to receive(:outstanding_payment_amount).and_return(outstanding_payment_amount)
      get :new, order_id: order.id
    end

    it 'creates a new Payment as @payment' do
      expect(assigns(:payment)).to be_kind_of Payment
    end

    it "sets the payment's order_id" do
      expect(assigns(:payment).order_id).to eq order.id
    end

    it "sets the payment amount to the order's outstanding payment amount" do
      expect(assigns(:payment).amount).to eq outstanding_payment_amount.to_s
    end
  end

  describe 'POST create' do
    let(:order) { FactoryGirl.create(:order) }

    context 'when successful' do
      it 'creates a new Payment' do
        expect{post_create}.to change{Payment.count}.by 1
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

    context 'when fail' do
      before do
        allow_any_instance_of(Payment).to receive(:save).and_return(false)
      end

      it 'renders new' do
        post_create
        expect(response).to render_template 'new'
      end

      it 'assigns @payment' do
        post_create
        expect(assigns(:payment)).to be_instance_of(Payment)
      end
    end

    def post_create
      post :create, payment: {service_provider: 'Cheque', amount: '10', order_id: order.id}
    end
  end
end
