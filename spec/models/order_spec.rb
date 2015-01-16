require 'rails_helper'

describe Order do
  describe '#to_s' do
    it 'returns its order number' do
      o = Order.new(order_number: '123')
      expect(o.to_s).to eq '123'
    end
  end

  describe '#record_preferred_delivery_date' do
    let(:date_format) { '%d/%m/%y' }
    let(:prompt) { 'Preferred delivery date' }
    let(:date_str) { '13/08/15' }
    let(:date) { Date.new(2015, 8, 13) }
    let(:settings) { PreferredDeliveryDateSettings.new(date_format: date_format, prompt: prompt) }

    subject(:order) { Order.new.record_preferred_delivery_date(settings, date_str) }

    it 'records the date, parsing with the format given in settings' do
      expect(order.preferred_delivery_date).to eq date
    end

    it 'records the prompt' do
      expect(order.preferred_delivery_date_prompt).to eq prompt
    end

    it 'records the format' do
      expect(order.preferred_delivery_date_format).to eq date_format
    end
  end

  describe '#add_basket' do
    let(:order) { Order.new }
    let(:basket) { Basket.new }

    it 'adds basket items' do
      expect(order).to receive(:add_basket_items).with(basket.basket_items)
      order.add_basket(basket)
    end

    it 'associates the basket with the order' do
      basket.save!
      order.add_basket(basket)
      expect(order.basket).to eq basket
    end
  end

  describe '#add_basket_items' do
    let(:basket) { FactoryGirl.create(:basket) }

    before do
      basket.basket_items << FactoryGirl.build(:basket_item)
      basket.basket_items << FactoryGirl.build(:basket_item)
    end

    it 'creates an order line for each basket item' do
      o = Order.new
      o.add_basket_items(basket.basket_items)
      expect(o.order_lines.length).to eq 2
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
