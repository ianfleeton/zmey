require 'rails_helper'

describe Order do
  describe '#to_s' do
    it 'returns its order number' do
      o = Order.new(order_number: '123')
      expect(o.to_s).to eq '123'
    end
  end

  describe '#copy_delivery_address' do
    before(:all) do
      @address = random_address
      @order = Order.new
      @order.copy_delivery_address(@address)
    end

    after(:all) { @address.country.destroy }

    from_to = {
      email_address:  :email_address,
      full_name:      :delivery_full_name,
      company:        :delivery_company,
      address_line_1: :delivery_address_line_1,
      address_line_2: :delivery_address_line_2,
      address_line_3: :delivery_address_line_3,
      town_city:      :delivery_town_city,
      county:         :delivery_county,
      country_id:     :delivery_country_id,
      phone_number:   :delivery_phone_number
    }.each do |from, to|
      it "copies address.#{from} to order.#{to}" do
        expect(@order.send(to)).to eq @address.send(from)
      end
    end
  end

  describe '#copy_billing_address' do
    before(:all) do
      @address = random_address
      @order = Order.new
      @order.copy_billing_address(@address)
    end

    after(:all) { @order.country.destroy }

    from_to = {
      full_name:      :billing_full_name,
      company:        :billing_company,
      address_line_1: :billing_address_line_1,
      address_line_2: :billing_address_line_2,
      address_line_3: :billing_address_line_3,
      town_city:      :billing_town_city,
      county:         :billing_county,
      country_id:     :billing_country_id,
      phone_number:   :billing_phone_number
    }.each do |from, to|
      it "copies address.#{from} to order.#{to}" do
        expect(@order.send(to)).to eq @address.send(from)
      end
    end
  end

  def random_address
    FactoryGirl.build(:address,
    email_address: "#{SecureRandom.hex}@example.org",
    company: SecureRandom.hex,
    address_line_1: SecureRandom.hex,
    address_line_2: SecureRandom.hex,
    address_line_3: SecureRandom.hex,
    town_city: SecureRandom.hex,
    county: SecureRandom.hex
    )
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
