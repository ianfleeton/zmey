require 'rails_helper'

RSpec.describe 'order_notifier/dispatch.html.erb', type: :view do
  let(:website) { FactoryGirl.create(:website) }
  let(:order) { FactoryGirl.create(:order) }
  let(:shipment) { FactoryGirl.create(:shipment, order: order) }

  before do
    assign(:website, website)
    assign(:order, order)
    assign(:shipment, shipment)
  end

  it 'renders' do
    render
  end
end
