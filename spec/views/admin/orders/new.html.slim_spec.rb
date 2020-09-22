require "rails_helper"

RSpec.describe "admin/orders/new.html.slim" do
  let(:order) { Order.new }
  let(:website) { FactoryBot.create(:website) }

  before do
    assign(:order, order)
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
    end
  end

  it "renders" do
    render
  end
end
