# frozen_string_literal: true

RSpec.shared_examples_for "a checker of updated baskets" do |method, action|
  let(:current_updated_at) { Time.current }

  before do
    allow(controller).to receive(:basket)
      .and_return(Basket.new(updated_at: current_updated_at))
  end

  context "when updated_at is older than loaded basket.updated_at" do
    let(:updated_at) { (current_updated_at - 1.minute).to_i }

    it "redirects to basket/updated_warning" do
      send(method, action, params: {updated_at: updated_at})
      expect(response).to redirect_to(basket_updated_warning_path)
    end
  end

  context "when updated_at is equal to the loaded basket.updated_at" do
    let(:updated_at) { current_updated_at.to_i }

    it "does not redirect to basket/updated_warning" do
      send(method, action, params: {updated_at: updated_at})
      expect(response).not_to redirect_to(basket_updated_warning_path)
    end
  end
end
