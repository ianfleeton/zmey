require "rails_helper"

RSpec.describe "api/admin/payments/show.json.jbuilder" do
  let(:payment) { FactoryBot.create(:payment) }

  before do
    assign(:payment, payment)
  end

  it "renders" do
    render
  end
end
