require 'rails_helper'

describe Order do
  describe '#to_s' do
    it 'returns its order number' do
      o = Order.new(order_number: '123')
      expect(o.to_s).to eq '123'
    end
  end

  describe '#to_webhook_payload' do
    before { FactoryGirl.create(:website) }

    context 'when event="order_created"' do
      let(:event) { 'order_created' }
      let(:order) { FactoryGirl.create(:order) }

      it 'returns a hash' do
        expect(order.to_webhook_payload(event)).to be_instance_of(Hash)
      end
    end
  end
end
