require 'rails_helper'

RSpec.describe Order, type: :model do
  it { should have_many(:order_comments).dependent(:delete_all).inverse_of(:order) }

  describe 'before_create :create_order_number' do
    let(:order) { FactoryGirl.build(:order, order_number: order_number) }
    before { order.save }

    context 'with blank order number' do
      let(:order_number) { nil }
      it 'creates an order number' do
        expect(order.order_number).to be_present
      end
    end

    context 'with existing order number' do
      let(:order_number) { 'ALREADYSET' }
      it 'preserves the order number' do
        expect(order.order_number).to eq order_number
      end
    end
  end

  describe '#to_s' do
    it 'returns its order number' do
      o = Order.new(order_number: '123')
      expect(o.to_s).to eq '123'
    end
  end

  describe '#amount_paid' do
    it 'returns the sum of accepted payment amounts' do
      o = FactoryGirl.create(:order)
      FactoryGirl.create(:payment, order: o, amount:  5, accepted: true)
      FactoryGirl.create(:payment, order: o, amount: 10, accepted: true)
      FactoryGirl.create(:payment, order: o, amount:  5, accepted: false)
      expect(o.amount_paid).to eq 15.0
    end
  end

  describe '#outstanding_payment_amount' do
    it 'returns the amount still left to be paid' do
      o = FactoryGirl.create(:order)
      o.total = 50
      FactoryGirl.create(:payment, order: o, amount:  5, accepted: true)
      FactoryGirl.create(:payment, order: o, amount: 10, accepted: true)
      expect(o.outstanding_payment_amount).to eq 35.0
    end
  end

  describe '#payment_accepted' do
    let(:order) { FactoryGirl.create(:order) }
    let(:payment) { FactoryGirl.build(:payment, order: order, amount: amount, accepted: true) }
    before do
      # Stub out payment communicating with order
      allow(payment).to receive(:notify_order)
      payment.save

      order.total = 10

      order.payment_accepted(payment)
    end

    context 'when payment less than needed' do
      let(:amount) { 5 }

      it 'leaves status WAITING_FOR_PAYMENT' do
        expect(order.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
      end
    end

    context 'when payment is in full' do
      let(:amount) { 10 }

      it 'transitions status to PAYMENT_RECEIVED and saves itself' do
        expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
      end
    end
  end

  describe '#copy_delivery_address' do
    before do
      @address = FactoryGirl.build(:random_address)
      @order = Order.new
      @order.copy_delivery_address(@address)
    end

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
    before do
      @address = FactoryGirl.build(:random_address)
      @order = Order.new
      @order.copy_billing_address(@address)
    end

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
    let(:product) { FactoryGirl.create(:product, rrp: 2.34) }
    let(:first_item) { FactoryGirl.build(:basket_item, product: product) }
    let(:order) { Order.new }

    before do
      basket.basket_items << first_item
      basket.basket_items << FactoryGirl.build(:basket_item)
      order.add_basket_items(basket.basket_items)
    end

    it 'creates an order line for each basket item' do
      expect(order.order_lines.length).to eq 2
    end

    it 'copies product RRP' do
      expect(order.order_lines.first.product_rrp).to eq product.rrp
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
