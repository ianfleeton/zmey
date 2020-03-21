require "rails_helper"

RSpec.describe Admin::OrderCommentsController, type: :controller do
  before do
    logged_in_as_admin
  end

  describe "POST create" do
    let(:order) { FactoryBot.create(:order) }

    context "when successful" do
      it "creates a new OrderComment" do
        expect { post_create }.to change { OrderComment.count }.by 1
      end

      it "redirects to edit order" do
        post_create
        expect(response).to redirect_to edit_admin_order_path(order)
      end
    end

    def post_create
      post :create, params: {order_comment: {comment: "Comment", order_id: order.id}}
    end
  end
end
