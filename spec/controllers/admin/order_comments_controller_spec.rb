require 'rails_helper'

describe Admin::OrderCommentsController do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
    logged_in_as_admin
  end

  describe 'GET new' do
    let(:order) { FactoryGirl.create(:order) }

    before do
      get :new, order_id: order.id
    end

    it 'creates a new OrderComment as @order_comment' do
      expect(assigns(:order_comment)).to be_kind_of OrderComment
    end

    it "sets the comment's order_id" do
      expect(assigns(:order_comment).order_id).to eq order.id
    end
  end

  describe 'POST create' do
    let(:order) { FactoryGirl.create(:order) }

    context 'when successful' do
      it 'creates a new OrderComment' do
        expect{post_create}.to change{OrderComment.count}.by 1
      end

      it 'redirects to edit order' do
        post_create
        expect(response).to redirect_to edit_admin_order_path(order)
      end
    end

    context 'when fail' do
      before do
        allow_any_instance_of(OrderComment).to receive(:save).and_return(false)
      end

      it 'renders new' do
        post_create
        expect(response).to render_template 'new'
      end

      it 'assigns @order_comment' do
        post_create
        expect(assigns(:order_comment)).to be_instance_of(OrderComment)
      end
    end

    def post_create
      post :create, order_comment: {comment: 'Comment', order_id: order.id}
    end
  end
end
