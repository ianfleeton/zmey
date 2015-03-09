require 'rails_helper'

RSpec.describe 'admin/orders/show.html.slim', type: :view do
  let(:order) { FactoryGirl.create(:order) }
  let(:website) { FactoryGirl.create(:website) }

  before do
    assign(:order, order)
    allow(view).to receive(:website).and_return(website)
  end

  context 'with payments' do
    before do
      FactoryGirl.create(:payment, order: order)
    end

    it 'renders payments' do
      render
      expect(view).to render_template '_payments'
    end
  end
end
