require 'rails_helper'

RSpec.describe 'orders/receipt.html.erb', type: :view do
  let(:order) { FactoryGirl.create(:order) }
  let(:website) { FactoryGirl.build(:website) }

  before do
    FactoryGirl.create(:order_line, order_id: order.id)
    order.reload
    assign(:order, order)

    assign(:w, website)
  end

  context 'as regular shopper' do
    before do
      allow(view).to receive(:admin?).and_return(false)
    end

    it 'renders' do
      render
    end
  end

  context 'as admin' do
    before do
      allow(view).to receive(:admin?).and_return(true)
    end

    it 'renders' do
      render
    end
  end
end
