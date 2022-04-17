require "rails_helper"

RSpec.describe "checkout/_yorkshire_payments_hidden_fields", type: :view do
  let(:website) {
    FactoryBot.build(
      :website,
      yorkshire_payments_merchant_id: "101380",
      yorkshire_payments_pre_shared_key: "secret"
    )
  }
  let(:order) { FactoryBot.create(:order) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
    end
    assign(:order, order)
    render
  end

  it "renders" do
    render
  end
end
