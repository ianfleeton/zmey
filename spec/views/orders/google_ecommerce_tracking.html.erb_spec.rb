require 'spec_helper'

describe 'orders/_google_ecommerce_tracking.html.erb' do
  let(:order) { FactoryGirl.create(:order) }

  before do
    view.stub(:website).and_return(order.website)
    assign(:order, order)
  end

  it 'renders' do
    render
  end
end
