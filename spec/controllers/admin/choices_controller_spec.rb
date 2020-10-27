require "rails_helper"

module Admin
  RSpec.describe ChoicesController, type: :controller do
    before do
      logged_in_as_admin
    end

    describe "GET new" do
      it "instantiates a new Choice" do
        allow(controller).to receive(:feature_valid?)
        expect(Choice).to receive(:new).and_return(double(Choice).as_null_object)
        get "new"
      end

      it "sets @choice.feature_id to the feature_id supplied as a parameter" do
        choice = Choice.new
        allow(Choice).to receive(:new).and_return(choice)
        get "new", params: {feature_id: 123}
        expect(choice.feature_id).to eq 123
      end

      context "when the feature is invalid" do
        it "redirects to the products page" do
          allow(controller).to receive(:feature_valid?).and_return(false)
          get "new"
          expect(response).to redirect_to(admin_products_path)
        end
      end
    end
  end
end
