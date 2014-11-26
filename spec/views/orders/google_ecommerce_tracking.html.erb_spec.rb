require 'rails_helper'

describe 'orders/_google_ecommerce_tracking.html.erb' do
  let(:order) { FactoryGirl.create(:order) }

  before do
    allow(view).to receive(:website).and_return(FactoryGirl.build(:website))
    assign(:order, order)
  end

  it 'renders' do
    render
  end
end
