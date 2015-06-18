require 'rails_helper'

RSpec.describe 'orders/_google_ecommerce_tracking.html.erb', type: :view do
  let(:order) { FactoryGirl.create(:order) }

  before do
    allow(view).to receive(:website).and_return(FactoryGirl.build(:website))
  end

  it 'renders' do
    render partial: 'google_ecommerce_tracking', locals: { order: order }
  end
end
