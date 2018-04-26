require 'rails_helper'

RSpec.describe 'admin/orders/record_sales_conversion', type: :view do
  let(:order) { FactoryBot.create(:order) }

  before do
    allow(order).to receive(:should_record_sales_conversion?).and_return(should_record_sales_conversion?)
    assign(:order, order)
  end

  context 'when order should record sales conversion' do
    let(:should_record_sales_conversion?) { true }
    it 'calls #record_sales_conversion' do
      expect(view).to receive(:record_sales_conversion)
      render
    end
  end

  context 'when order should not record sales conversion' do
    let(:should_record_sales_conversion?) { false }
    it 'does not call #record_sales_conversion' do
      expect(view).not_to receive(:record_sales_conversion)
      render
    end
  end
end
