shared_examples_for "a suspended shop bouncer" do
  describe "before_actions" do
    let(:website) {
      Website.new(
        shopping_suspended: shopping_suspended,
        shopping_suspended_message: shopping_suspended_message
      )
    }

    controller do
      def index
        render text: "Dummy"
      end
    end

    describe ":bounce_suspended_shopping" do
      let(:shopping_suspended) { true }
      let(:shopping_suspended_message) { "Suspended due to REASON" }
      it "redirects to the home page" do
        get :index
        expect(response).to redirect_to root_path
      end
      it "sets a flash notice" do
        get :index
        expect(flash[:notice]).to eq shopping_suspended_message
      end
    end
  end
end
