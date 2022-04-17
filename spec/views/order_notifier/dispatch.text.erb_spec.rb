require "rails_helper"

RSpec.describe "order_notifier/dispatch.text", type: :view do
  let(:website) { FactoryBot.create(:website) }
  let(:order) { FactoryBot.create(:order) }
  let(:shipment) { FactoryBot.create(:shipment, order: order) }

  before do
    assign(:website, website)
    assign(:order, order)
    assign(:shipment, shipment)
  end

  it "renders" do
    render
  end
end
