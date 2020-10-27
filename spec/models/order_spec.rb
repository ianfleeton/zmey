require "rails_helper"

RSpec.describe Order, type: :model do
  FactoryBot.use_parent_strategy = false

  context "uniqueness" do
    before { FactoryBot.create(:order, order_number: "AB123") }
    it { should validate_uniqueness_of :order_number }
  end

  # Irish VAT numbers
  it { should allow_value("IE1234567X").for(:vat_number) }
  it { should allow_value("IE1X23456X").for(:vat_number) }
  # Irish VAT numbers since January 2013
  it { should allow_value("IE1234567NH").for(:vat_number) }

  context "if requires delivery address" do
    before { subject.requires_delivery_address = true }
    it { should validate_presence_of(:delivery_address_line_1) }
    it { should validate_presence_of(:delivery_town_city) }
    it { should validate_presence_of(:delivery_postcode) }
    it { should validate_presence_of(:delivery_country_id) }
  end

  context "if does not require delivery address" do
    before { subject.requires_delivery_address = false }
    it { should_not validate_presence_of(:delivery_address_line_1) }
    it { should_not validate_presence_of(:delivery_town_city) }
    it { should_not validate_presence_of(:delivery_postcode) }
    it { should_not validate_presence_of(:delivery_country_id) }
  end

  describe "associations" do
    it { should have_many(:collection_ready_emails).dependent(:delete_all) }
    it { should have_many(:discount_uses).dependent(:delete_all) }
    it { should have_many(:discounts).through(:discount_uses) }
    it { should have_many(:locations).through(:product_groups) }
    it { should have_many(:order_comments).dependent(:delete_all).inverse_of(:order) }
    it { should have_many(:product_groups).through(:products) }
    it { should have_many(:products).through(:order_lines) }
    it { should have_many(:shipments).dependent(:delete_all).inverse_of(:order) }
  end

  describe "before_create :create_order_number" do
    let(:order) { FactoryBot.build(:order, order_number: order_number) }

    context "with blank order number" do
      let(:order_number) { nil }
      it "creates an order number" do
        order.save
        expect(order.order_number).to be_present
      end

      it "requests an order number generator for itself" do
        expect(OrderNumberGenerator).to receive(:get_generator).with(order).and_call_original
        order.create_order_number
      end

      it "sets its order number from the generator" do
        allow(OrderNumberGenerator)
          .to receive(:get_generator)
          .and_return(double(OrderNumberGenerator::Base,
            generate: "ORDER1234"))
        order.create_order_number
        expect(order.order_number).to eq "ORDER1234"
      end
    end

    context "with existing order number" do
      let(:order_number) { "ALREADYSET" }
      it "preserves the order number" do
        order.save
        expect(order.order_number).to eq order_number
      end
    end
  end

  describe "before_validation :associate_with_user" do
    let(:user1) { FactoryBot.create(:user) }
    let(:user2) { FactoryBot.create(:user, email: "c2@example.org") }
    let(:nobody) do
      FactoryBot.create(:user, email: Address::PLACEHOLDER_EMAIL)
    end
    let(:order_user) { nil }
    let(:order) do
      FactoryBot.build(
        :order,
        email_address: "c2@example.org",
        user: order_user,
        billing_full_name: "Alice"
      )
    end

    context "with user set" do
      let(:order_user) { user1 }

      it "does not link the order to another users account with a matching " \
      "email" do
        expect(User).not_to receive(:find_or_create_by_details)
        order.valid?
        expect(order.user).to eq(user1)
      end

      context "when user email is the address placeholder email" do
        let(:order_user) { nobody }

        it "finds or creates the user based on the order email address" do
          expect(User).to receive(:find_or_create_by_details)
            .with(email: "c2@example.org", name: "Alice").and_return(user2)
          order.valid?
          expect(order.user).to eq(user2)
        end
      end
    end

    context "with user not set" do
      it "gets the user based on the order email address" do
        expect(User).to receive(:find_or_create_by_details)
          .with(email: "c2@example.org", name: "Alice").and_return(user2)
        order.valid?
        expect(order.user).to eq(user2)
      end
    end
  end

  describe ".matching_new_payment" do
    it "returns nil when there is no matching order" do
      FactoryBot.create(:order, order_number: "111222")
      match = Order.matching_new_payment(Payment.new(cart_id: "333444"))
      expect(match).to be_nil
    end

    it "finds the order whose number matches the payment cart_id" do
      order = FactoryBot.create(:order, order_number: "333444")
      match = Order.matching_new_payment(Payment.new(cart_id: "333444"))
      expect(match).to eq order
    end
  end

  describe ".current" do
    it "finds order with matching id" do
      order = FactoryBot.create(:order)
      cookies = instance_double(
        ActionDispatch::Cookies::CookieJar, signed: {order_id: order.id}
      )
      expect(Order.current(cookies)).to eq order
    end

    it "returns nil with non-matching id" do
      cookies = instance_double(
        ActionDispatch::Cookies::CookieJar, signed: {order_id: 1}
      )
      expect(Order.current(cookies)).to be_nil
    end
  end

  describe ".current!" do
    it "finds order with matching id" do
      order = FactoryBot.create(:order)
      cookies = instance_double(
        ActionDispatch::Cookies::CookieJar, signed: {order_id: order.id}
      )
      expect(Order.current!(cookies)).to eq order
    end

    it "raises an ActiveRecord::RecordNotFound error with non-matching id" do
      cookies = instance_double(
        ActionDispatch::Cookies::CookieJar, signed: {order_id: 1}
      )
      expect { Order.current!(cookies) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#to_s" do
    it "returns its order number" do
      o = Order.new(order_number: "123")
      expect(o.to_s).to eq "123"
    end
  end

  describe "#can_update_basket?" do
    it "returns false when payment received, on account, quote or pay by " \
    "phone" do
      [
        Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE,
        Enums::PaymentStatus::PAYMENT_RECEIVED,
        Enums::PaymentStatus::PAYMENT_ON_ACCOUNT,
        Enums::PaymentStatus::QUOTE,
        Enums::PaymentStatus::PAY_BY_PHONE
      ].each do |status|
        expect(
          Order.new(status: status).can_update_basket?
        ).to be_falsey
      end
    end

    it "returns true when any other status" do
      [
        Enums::PaymentStatus::ORDER_NOT_PLACED,
        Enums::PaymentStatus::WAITING_FOR_PAYMENT,
        Enums::PaymentStatus::PRO_FORMA
      ].each do |status|
        expect(
          Order.new(status: status).can_update_basket?
        ).to be_truthy
      end
    end
  end

  describe "#amount_paid" do
    it "returns the sum of accepted payment amounts" do
      o = FactoryBot.create(:order)
      FactoryBot.create(:payment, order: o, amount: 5, accepted: true)
      FactoryBot.create(:payment, order: o, amount: 10, accepted: true)
      FactoryBot.create(:payment, order: o, amount: 5, accepted: false)
      expect(o.amount_paid).to eq 15.0
    end
  end

  describe "#outstanding_payment_amount" do
    it "returns the amount still left to be paid" do
      o = FactoryBot.build(:order)
      line = FactoryBot.build(:order_line, product_price: 50, quantity: 1)
      o.order_lines << line

      FactoryBot.create(:payment, order: o, amount: 5, accepted: true)
      FactoryBot.create(:payment, order: o, amount: 10, accepted: true)
      expect(o.outstanding_payment_amount).to eq 35.0
    end
  end

  describe "#shippable?" do
    let(:on_hold) { false }
    let(:status) { Enums::PaymentStatus::PAYMENT_RECEIVED }
    let(:order) { Order.new(on_hold: on_hold, status: status) }

    it "is shippable when payment is received" do
      expect(order.shippable?).to eq(true)
    end

    it "is shippable when payment is on account" do
      order.status = Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
      expect(order.shippable?).to eq(true)
    end

    it "is not shippable when the order is on hold" do
      order.on_hold = true
      expect(order.shippable?).to eq(false)
    end

    it "is not shippable when the order is for collection" do
      order.shipping_method = "Collection"
      expect(order.shippable?).to eq(false)
    end

    it "is not shippable when status is not payment received or payment on " \
    "account" do
      order.status = Enums::PaymentStatus::QUOTE
      expect(order.shippable?).to eq(false)
      order.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
      expect(order.shippable?).to eq(false)
    end
  end

  describe "#collectable?" do
    def collectable_order
      co = FactoryBot.build(
        :order,
        status: Enums::PaymentStatus::PAYMENT_RECEIVED,
        shipping_method: "Collection"
      )
      yield co if block_given?
      co
    end

    subject { order.collectable? }

    context "when order is paid, unheld, and method is collection" do
      let(:order) { collectable_order }
      it { should be_truthy }
    end

    context "when order is unpaid" do
      let(:order) do
        collectable_order do |o|
          o.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
        end
      end
      it { should be_falsey }
    end

    context "when order is on hold" do
      let(:order) do
        collectable_order do |o|
          o.on_hold = true
        end
      end
      it { should be_falsey }
    end

    context "when order is payment on account" do
      let(:order) do
        collectable_order do |o|
          o.status = Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
        end
      end
      it { should be_truthy }
    end

    context "when order has a shipping method other than Collection" do
      let(:order) do
        collectable_order do |o|
          o.shipping_method = "Mainland UK"
        end
      end
      it { should be_falsey }
    end

    context "when order is already shipped" do
      let(:order) { collectable_order }
      before do
        order.save
        FactoryBot.create(
          :shipment, order: order, partial: false, shipped_at: Time.current
        )
      end
      it { should be_falsey }
    end
  end

  describe "#collection?" do
    it "only returns true when shipping method = Collection" do
      expect(Order.new(shipping_method: "Collection").collection?).to eq true
      expect(Order.new(shipping_method: "Mainland UK").collection?).to eq false
    end
  end

  describe "#payment_accepted" do
    let(:initial_status) { Enums::PaymentStatus::WAITING_FOR_PAYMENT }
    let(:order_total) { 10 }
    let(:order) { FactoryBot.create(:order, status: initial_status) }
    let(:payment) { FactoryBot.build(:payment, order: order, amount: amount, accepted: true) }
    before do
      # Stub out payment communicating with order
      allow(payment).to receive(:notify_order)
      # Prevent recalculation of order total since we have no line items in this
      # spec
      allow(order).to receive(:calculate_total)
      payment.save

      order.total = order_total

      order.payment_accepted(payment)
    end

    context "when payment less than needed" do
      let(:amount) { 5 }

      it "leaves status WAITING_FOR_PAYMENT" do
        expect(order.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
      end
    end

    context "when payment is in full" do
      let(:amount) { 10 }

      it "transitions status to PAYMENT_RECEIVED and saves itself" do
        expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
      end
    end

    context "payment is negative" do
      let(:amount) { -5 }

      context "initial status is PAYMENT_RECEIVED" do
        let(:initial_status) { Enums::PaymentStatus::PAYMENT_RECEIVED }

        it "transitions status to WAITING_FOR_PAYMENT and saves itself" do
          expect(order.reload.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
        end

        context "but no payment amount outstanding" do
          let(:order_total) { -5 }

          it "leaves the order status untouched" do
            expect(order.reload.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
          end
        end
      end
    end
  end

  describe "#fully_paid" do
    let(:invoice_time) { nil }
    let(:order) { FactoryBot.build(:order, invoiced_at: invoice_time) }

    context "when order is not fully shipped" do
      it "updates the estimated delivery date" do
        order.fully_paid
        expect(order.estimated_delivery_date).to be
      end
    end

    context "when order is fully shipped" do
      before do
        order.save
        FactoryBot.create(
          :shipment, order: order, partial: false, shipped_at: Time.current
        )
      end

      it "leaves the estimated delivery date alone" do
        order.fully_paid
        expect(order.estimated_delivery_date).to be_nil
      end
    end
  end

  describe "#copy_delivery_address" do
    before do
      @address = FactoryBot.build(:random_address)
      @order = Order.new
      @order.copy_delivery_address(@address)
    end

    {
      full_name: :delivery_full_name,
      company: :delivery_company,
      address_line_1: :delivery_address_line_1,
      address_line_2: :delivery_address_line_2,
      address_line_3: :delivery_address_line_3,
      town_city: :delivery_town_city,
      county: :delivery_county,
      country_id: :delivery_country_id,
      phone_number: :delivery_phone_number
    }.each do |from, to|
      it "copies address.#{from} to order.#{to}" do
        expect(@order.send(to)).to eq @address.send(from)
      end
    end
  end

  describe "#copy_billing_address" do
    before do
      @address = FactoryBot.build(:random_address)
      @order = Order.new
      @order.copy_billing_address(@address)
    end

    {
      email_address: :email_address,
      full_name: :billing_full_name,
      company: :billing_company,
      address_line_1: :billing_address_line_1,
      address_line_2: :billing_address_line_2,
      address_line_3: :billing_address_line_3,
      town_city: :billing_town_city,
      county: :billing_county,
      country_id: :billing_country_id,
      phone_number: :billing_phone_number
    }.each do |from, to|
      it "copies address.#{from} to order.#{to}" do
        expect(@order.send(to)).to eq @address.send(from)
      end
    end
  end

  describe "#calculate_total" do
    it "calculates and assigns the order grand total to self.total" do
      order = Order.new(shipping_amount: 1, shipping_tax_amount: 0.2)
      order.order_lines << OrderLine.new(
        quantity: 1, product_price: 3, tax_amount: 0.6
      )
      order.calculate_total
      expect(order.total).to eq 4.8
    end
  end

  shared_examples_for "a WAITING_FOR_PAYMENT to PAYMENT_RECEIVED transition" do
    let(:order) { Order.new(total: total, status: initial_status) }

    before { order.update_payment_status }

    subject { order.status }

    context "when initial status is WAITING_FOR_PAYMENT" do
      let(:initial_status) { Enums::PaymentStatus::WAITING_FOR_PAYMENT }
      it { should eq Enums::PaymentStatus::PAYMENT_RECEIVED }
    end

    context "when initial status is anything else" do
      let(:initial_status) { Enums::PaymentStatus::QUOTE }
      it { should eq Enums::PaymentStatus::QUOTE }
    end
  end

  describe "#update_payment_status" do
    context "when there is an outstanding payment amount" do
      let(:order) { Order.new(total: 1, status: initial_status) }

      before { order.update_payment_status }

      subject { order.status }

      context "when initial status is PAYMENT_RECEIVED" do
        let(:initial_status) { Enums::PaymentStatus::PAYMENT_RECEIVED }
        it { should eq Enums::PaymentStatus::WAITING_FOR_PAYMENT }
      end

      context "when initial status is anything else" do
        let(:initial_status) { Enums::PaymentStatus::QUOTE }
        it { should eq Enums::PaymentStatus::QUOTE }
      end
    end

    context "when there is no outstanding payment amount" do
      let(:total) { 0 }
      it_behaves_like "a WAITING_FOR_PAYMENT to PAYMENT_RECEIVED transition"
    end

    context "when the outstanding payment amount is negative" do
      let(:total) { -5 }
      it_behaves_like "a WAITING_FOR_PAYMENT to PAYMENT_RECEIVED transition"
    end
  end

  describe "#shipping_amount_gross" do
    before do
      @order = FactoryBot.build(
        :order, shipping_amount: 10, shipping_tax_amount: 2
      )
    end

    context "when not zero-rated" do
      it "returns the shipping amount including tax" do
        expect(@order.shipping_amount_gross).to eq 12
      end
    end

    context "when zero-rated" do
      before do
        make_order_zero_rated(@order)
      end

      it "returns the shipping amount excluding tax" do
        expect(@order.shipping_amount_gross).to eq 10
      end
    end
  end

  def make_order_zero_rated(order)
    allow(Orders::TaxStatus)
      .to receive(:new)
      .with(order)
      .and_return(instance_double(Orders::TaxStatus, zero_rated?: true))
  end

  describe "#line_total_net" do
    context "without order lines" do
      it "returns a BigDecimal zero" do
        ltn = Order.new.line_total_net
        expect(ltn).to be_zero
        expect(ltn.class).to eq BigDecimal
      end
    end
  end

  describe "#line_total_gross" do
    before do
      @order = FactoryBot.create(:order)
    end

    context "without order lines" do
      it "returns a BigDecimal zero" do
        ltg = @order.line_total_gross
        expect(ltg).to be_zero
        expect(ltg.class).to eq BigDecimal
      end
    end

    context "with order lines" do
      before do
        @order.order_lines << FactoryBot.build(
          :order_line, product_price: 5, quantity: 2, tax_amount: 2
        )
        @order.order_lines << FactoryBot.build(
          :order_line, product_price: 4, quantity: 1, tax_amount: 0.8
        )
      end

      context "when not zero-rated" do
        it "returns the sum of line totals including tax" do
          expect(@order.line_total_gross).to eq 16.8
        end
      end

      context "when zero-rated" do
        before do
          make_order_zero_rated(@order)
        end

        it "returns the sum of line totals excluding tax" do
          expect(@order.line_total_gross).to eq 14
        end
      end
    end
  end

  describe "#add_basket" do
    let(:customer_note) { "customer note" }
    let(:delivery_instructions) { "delivery instructions" }
    let(:order) { Order.new }
    let(:basket) { Basket.new(customer_note: customer_note, delivery_instructions: delivery_instructions) }

    it "adds basket items" do
      lines = [OrderLine.new, OrderLine.new]

      allow(basket).to receive(:to_order_lines).and_return(lines)
      expect(order).to receive(:add_lines).with(lines)

      order.add_basket(basket)
    end

    it "associates the basket with the order" do
      basket.save!
      order.add_basket(basket)
      expect(order.basket).to eq basket
    end

    it "copies the customer_note" do
      order.add_basket(basket)
      expect(order.customer_note).to eq customer_note
    end

    it "copies the delivery_instructions" do
      order.add_basket(basket)
      expect(order.delivery_instructions).to eq delivery_instructions
    end
  end

  describe "#add_discount_lines" do
    it "adds lines" do
      ol1 = OrderLine.new
      ol2 = OrderLine.new
      discount_lines = [
        instance_double(DiscountLine, to_order_line: ol1),
        instance_double(DiscountLine, to_order_line: ol2)
      ]
      order = Order.new
      order.add_discount_lines(discount_lines)
      expect(order.order_lines.first).to eq ol1
      expect(order.order_lines.last).to eq ol2
    end
  end

  describe "#add_basket_items" do
    let(:basket) { FactoryBot.create(:basket) }
    let(:product) { FactoryBot.create(:product, rrp: 2.34) }
    let(:first_item) { FactoryBot.build(:basket_item, product: product) }
    let(:order) { Order.new }

    before do
      basket.basket_items << first_item
      basket.basket_items << FactoryBot.build(:basket_item)
      order.add_basket_items(basket.basket_items)
    end

    it "creates an order line for each basket item" do
      expect(order.order_lines.length).to eq 2
    end

    it "copies product RRP" do
      expect(order.order_lines.first.product_rrp).to eq product.rrp
    end
  end

  describe "#lead_time" do
    it "returns the highest value for lead time in order lines" do
      line1 = instance_double(OrderLine, lead_time: 3)
      line2 = instance_double(OrderLine, lead_time: 4)
      order = Order.new
      allow(order).to receive(:order_lines).and_return [line1, line2]
      expect(order.lead_time).to eq 4
    end

    it "returns 0 when the order is empty" do
      order = Order.new
      expect(order.lead_time).to eq 0
    end
  end

  describe "#relevant_dispatch_date" do
    let(:order) { FactoryBot.build(:order, dispatch_date: dispatch_date) }

    subject { order.relevant_dispatch_date }

    context "dispatch date" do
      let(:dispatch_date) { Date.today }

      it { should eq Date.today }
    end

    context "without dispatch date" do
      let(:dispatch_date) { nil }

      it { should eq Date.yesterday }
    end
  end

  describe "#update_estimated_delivery_date" do
    let(:order) { Order.new }
    let(:odd) do
      instance_double(
        Shipping::OrderDispatchDelivery,
        delivery_dates: [Date.new(2017, 7, 19)],
        dispatch_date: Date.new(2017, 7, 18)
      )
    end

    it "sets its estimated_delivery_date to a new estimate" do
      allow(Shipping::OrderDispatchDelivery)
        .to receive(:new)
        .and_return(odd)

      order.update_estimated_delivery_date

      expect(order.estimated_delivery_date).to eq Date.new(2017, 7, 19)
    end

    it "sets its dispatch_date" do
      allow(Shipping::OrderDispatchDelivery)
        .to receive(:new)
        .and_return(odd)

      order.update_estimated_delivery_date

      expect(order.dispatch_date).to eq Date.new(2017, 7, 18)
    end

    context "when order has delivery_date set" do
      let(:order) { Order.new(delivery_date: Date.new(2017, 7, 19)) }
      it "does not update the estimated delivery date" do
        order.update_estimated_delivery_date
        expect(order.estimated_delivery_date).to be_nil
      end
    end
  end

  describe "#fully_shipped?" do
    let(:order) { FactoryBot.create(:order) }
    let!(:shipment) { FactoryBot.create(:shipment, order: order, shipped_at: shipped_at, partial: partial) }
    subject { order.fully_shipped? }

    context "partial shipment" do
      let(:partial) { true }
      context "shipped" do
        let(:shipped_at) { Time.zone.now }
        it { should eq false }
      end
      context "unshipped" do
        let(:shipped_at) { nil }
        it { should eq false }
      end
    end

    context "full shipment" do
      let(:partial) { false }
      context "shipped" do
        let(:shipped_at) { Time.zone.now }
        it { should eq true }
      end
      context "unshipped" do
        let(:shipped_at) { nil }
        it { should eq false }
      end
    end
  end

  describe "#to_webhook_payload" do
    before { FactoryBot.create(:website) }

    context 'when event="order_created"' do
      let(:event) { "order_created" }
      let(:order) { FactoryBot.create(:order) }

      it "returns a hash" do
        expect(order.to_webhook_payload(event)).to be_instance_of(Hash)
      end
    end
  end

  describe "#billing_country_name=" do
    it "sets billing_country to the named country" do
      country = FactoryBot.create(:country)
      order = Order.new
      order.billing_country_name = country.name
      expect(order.billing_country).to eq country
    end
  end

  describe "#delivery_country_name=" do
    it "sets delivery_country to the named country" do
      country = FactoryBot.create(:country)
      order = Order.new
      order.delivery_country_name = country.name
      expect(order.delivery_country).to eq country
    end
  end

  shared_examples_for "a VAT number tidier" do |message|
    it "converts a blank VAT number to nil" do
      order = Order.new(vat_number: "")
      order.send(message)
      expect(order.vat_number).to be_nil
    end

    it "strips spaces and other non alpha-numerics" do
      order = Order.new(vat_number: "GB 123?")
      order.send(message)
      expect(order.vat_number).to eq "GB123"
    end

    it "upcases the VAT number" do
      order = Order.new(vat_number: "gb123")
      order.send(message)
      expect(order.vat_number).to eq "GB123"
    end
  end

  describe "#tidy_vat_number" do
    it_behaves_like "a VAT number tidier", :tidy_vat_number
  end

  describe "before_validation :tidy_vat_number" do
    it_behaves_like "a VAT number tidier", :valid?
  end
end
