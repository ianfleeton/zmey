require 'rails_helper'

RSpec.describe Order, type: :model do
  context 'uniqueness' do
    before { FactoryGirl.create(:order) }
    it { should validate_uniqueness_of :order_number }
  end

  it { should have_many(:order_comments).dependent(:delete_all).inverse_of(:order) }
  it { should have_many(:shipments).dependent(:delete_all).inverse_of(:order) }

  context 'if requires delivery address' do
    before { subject.requires_delivery_address = true }
    it { should validate_presence_of(:delivery_address_line_1) }
    it { should validate_presence_of(:delivery_town_city) }
    it { should validate_presence_of(:delivery_postcode) }
    it { should validate_presence_of(:delivery_country_id) }
  end

  context 'if does not require delivery address' do
    before { subject.requires_delivery_address = false }
    it { should_not validate_presence_of(:delivery_address_line_1) }
    it { should_not validate_presence_of(:delivery_town_city) }
    it { should_not validate_presence_of(:delivery_postcode) }
    it { should_not validate_presence_of(:delivery_country_id) }
  end

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

  describe '.new_or_recycled' do
    subject { Order.new_or_recycled(id) }

    context 'when order_id nil' do
      let(:id) { nil }
      it { should be_instance_of(Order) }
      it 'is new' do
        expect(subject.new_record?).to eq true
      end
    end

    context 'when order exists' do
      let(:order) { FactoryGirl.create(:order, status: status) }
      let(:id) { order.id }

      context 'when status is waiting for payment' do
        let(:status) { Enums::PaymentStatus::WAITING_FOR_PAYMENT }
        it { should eq order }

        context 'with order lines' do
          before do
            FactoryGirl.create(:order_line, order: order)
          end
          it 'deletes order lines' do
            expect(subject.order_lines.count).to eq 0
          end
        end
      end

      context 'when status is not waiting for payment' do
        let(:status) { Enums::PaymentStatus::QUOTE }
        it { should be_instance_of(Order) }
        it 'is new' do
          expect(subject.new_record?).to eq true
        end
      end
    end

    context 'when order does not exist' do
      let(:id) { 123 }
      it { should be_instance_of(Order) }
      it 'is new' do
        expect(subject.new_record?).to eq true
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
    let(:valid_date?) { nil }

    subject(:order) { Order.new.record_preferred_delivery_date(settings, date_str) }

    before do
      allow(settings).to receive(:valid_date?).and_return(valid_date?) if settings
    end

    context 'when date is valid according to settings' do
      let(:valid_date?) { true }

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

    context 'with nil settings' do
      let(:settings) { nil }
      it 'returns nil' do
        expect(order).to be_nil
      end
    end

    context 'when date is not valid according to settings' do
      let(:valid_date?) { false }

      it 'raises an ArgumentError' do
        expect { order }.to raise_error ArgumentError
      end
    end
  end

  describe '#add_basket' do
    let(:customer_note) { 'customer note' }
    let(:delivery_instructions) { 'delivery instructions' }
    let(:order) { Order.new }
    let(:basket) { Basket.new(customer_note: customer_note, delivery_instructions: delivery_instructions) }

    it 'adds basket items' do
      expect(order).to receive(:add_basket_items).with(basket.basket_items)
      order.add_basket(basket)
    end

    it 'associates the basket with the order' do
      basket.save!
      order.add_basket(basket)
      expect(order.basket).to eq basket
    end

    it 'copies the customer_note' do
      order.add_basket(basket)
      expect(order.customer_note).to eq customer_note
    end

    it 'copies the delivery_instructions' do
      order.add_basket(basket)
      expect(order.delivery_instructions).to eq delivery_instructions
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

  describe '#fully_shipped?' do
    let(:order) { FactoryGirl.create(:order) }
    let!(:shipment) { FactoryGirl.create(:shipment, order: order, shipped_at: shipped_at, partial: partial)}
    subject { order.fully_shipped? }

    context 'partial shipment' do
      let(:partial) { true }
      context 'shipped' do
        let(:shipped_at) { Time.zone.now }
        it { should eq false }
      end
      context 'unshipped' do
        let(:shipped_at) { nil }
        it { should eq false }
      end
    end

    context 'full shipment' do
      let(:partial) { false }
      context 'shipped' do
        let(:shipped_at) { Time.zone.now }
        it { should eq true }
      end
      context 'unshipped' do
        let(:shipped_at) { nil }
        it { should eq false }
      end
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

  describe '#billing_country_name=' do
    it 'sets billing_country to the named country' do
      country = FactoryGirl.create(:country)
      order = Order.new
      order.billing_country_name = country.name
      expect(order.billing_country).to eq country
    end
  end

  describe '#delivery_country_name=' do
    it 'sets delivery_country to the named country' do
      country = FactoryGirl.create(:country)
      order = Order.new
      order.delivery_country_name = country.name
      expect(order.delivery_country).to eq country
    end
  end

  describe '#should_record_sales_conversion?' do
    let(:order) { Order.new(
      sales_conversion_recorded_at: sales_conversion_recorded_at
    ) }
    let(:payment_received?) { true }
    let(:sales_conversion_recorded_at) { nil }

    subject { order.should_record_sales_conversion? }

    before do
      allow(order).to receive(:payment_received?).and_return(payment_received?)
    end

    context 'when conversion already recorded' do
      let(:sales_conversion_recorded_at) { Date.today }
      it { should eq false }
    end

    context 'when payment not received' do
      let(:payment_received?) { false }
      it { should eq false }
    end

    context 'when conversion not recorded and payment received' do
      it { should eq true }
    end
  end

  describe '#record_sales_conversion!' do
    let(:order) { FactoryGirl.build(:order) }

    it 'updates sales_conversion_recorded_at' do
      order.record_sales_conversion!
      expect(order.sales_conversion_recorded_at).to be
    end

    it 'saves the order' do
      order.record_sales_conversion!
      expect(order.persisted?).to eq true
    end
  end
end
