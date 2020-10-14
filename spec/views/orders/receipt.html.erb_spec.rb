require "rails_helper"

RSpec.describe "orders/receipt.html.erb", type: :view do
  let(:order) { FactoryBot.create(:order) }
  let(:website) { FactoryBot.build(:website) }

  before do
    FactoryBot.create(:order_line, order_id: order.id)
    order.reload
    assign(:order, order)

    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
    end
  end

  context "as regular shopper" do
    before do
      without_partial_double_verification do
        allow(view).to receive(:admin?).and_return(false)
      end
    end

    it "renders" do
      render
    end
  end

  context "as admin" do
    before do
      without_partial_double_verification do
        allow(view).to receive(:admin?).and_return(true)
      end
    end

    it "renders" do
      render
    end
  end
end
