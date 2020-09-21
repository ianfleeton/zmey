require "rails_helper"

describe "orders/invoice.html.slim" do
  it "renders" do
    assign(:order, FactoryBot.create(:order))
    without_partial_double_verification do
      allow(view).to receive(:website).and_return FactoryBot.build(:website)
    end

    render
  end
end
