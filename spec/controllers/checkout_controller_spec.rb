# frozen_string_literal: true

require "rails_helper"
require_relative "shared_examples/shopping_suspended"
require_relative "shared_examples/check_updated_baskets"

RSpec.describe CheckoutController, type: :controller do
  render_views

  FactoryBot.use_parent_strategy = false

  def cookies
    ActionDispatch::Request.new(request.env).cookie_jar
  end

  let(:website) { Website.new }
  before { allow(controller).to receive(:website).and_return(website) }
  let!(:uk) { FactoryBot.create(:country, name: Country::UNITED_KINGDOM) }

  it_behaves_like "a suspended shop bouncer"

  shared_examples_for "a checkout advancer" do |method, action|
    let(:all_checkout_details) { true }
    let(:billing_address) { FactoryBot.create(:address) }
    let(:delivery_address_valid?) { true }
    let(:shipping_class_valid?) { true }

    before do
      allow(controller).to receive(:all_checkout_details?)
        .and_return(all_checkout_details)
      allow(controller).to receive(:billing_address).and_return(billing_address)
      allow(controller).to receive(:delivery_address_valid?)
        .and_return(delivery_address_valid?)
      allow(controller).to receive(:shipping_class_valid?)
        .and_return(shipping_class_valid?)
      send(method, action, params: params)
    end

    context "without name, phone, mobile, and email set in session" do
      let(:all_checkout_details) { false }
      it { should redirect_to checkout_details_path }
    end

    context "without billing details" do
      let(:billing_address) { nil }
      it { should redirect_to billing_details_path }
    end

    context "without delivery details" do
      let(:delivery_address_valid?) { false }
      it { should redirect_to delivery_details_path }
    end

    context "without a valid shipping class" do
      let(:shipping_class_valid?) { false }
      it { should redirect_to delivery_details_path }
    end

    context "with all details" do
      it { should redirect_to confirm_checkout_path }
    end
  end

  describe "GET index" do
    context "with empty basket" do
      before { get :index }

      it { should redirect_to basket_path }
    end

    context "with items in the basket" do
      before { add_items_to_basket }

      let(:params) { {} }
      it_behaves_like "a checkout advancer", :get, :index

      it_behaves_like "a checker of updated baskets", :get, :index
    end
  end

  describe "GET details" do
    let(:current_user) { User.new }
    let(:name) { nil }
    let(:email) { nil }
    let(:phone) { nil }
    let(:mobile) { nil }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)

      get :details, session: {
        name: name,
        email: email,
        phone: phone,
        mobile: mobile
      }
    end

    context "when logged in" do
      let(:current_user) do
        double(
          User,
          name: "joe", email: "joe@example.com",
          phone_number: "1", mobile_number: "2",
          persisted?: true, admin?: false
        )
      end

      it "sets source in session to checkout/details" do
        expect(session[:source]).to eq "checkout/details"
      end

      context "when details blank" do
        it "populates name, email, phone, and mobile from user account" do
          expect(session[:name]).to eq current_user.name
          expect(session[:email]).to eq current_user.email
          expect(session[:phone]).to eq "1"
          expect(session[:mobile]).to eq "2"
        end
      end

      context "when details present" do
        let(:name) { "untouched" }
        let(:email) { "untouched" }
        let(:phone) { "untouched" }
        let(:mobile) { "untouched" }

        it "leaves details untouched" do
          expect(session[:name]).to eq name
          expect(session[:email]).to eq email
          expect(session[:phone]).to eq phone
          expect(session[:mobile]).to eq mobile
        end
      end
    end
  end

  describe "POST save_details" do
    context "with valid details" do
      before do
        post :save_details, params: {
          mobile: "0", name: "n", phone: "1", email: "x"
        }
      end

      it { should set_session[:mobile].to("0") }
      it { should set_session[:name].to("n") }
      it { should set_session[:phone].to("1") }
      it { should set_session[:email].to("x") }

      let(:params) { {name: "n", phone: "1", email: "x"} }
      it_behaves_like("a checkout advancer", :post, :save_details)

      it "updates basket details" do
        basket = Basket.last
        expect(basket.email).to eq "x"
        expect(basket.mobile).to eq "0"
        expect(basket.name).to eq "n"
        expect(basket.phone).to eq "1"
      end
    end
  end

  shared_examples_for "an address prefiller" do
    it "prefills some of the address from session details" do
      assert_select('input#address_full_name[value="n"]')
      assert_select('input#address_phone_number[value="1"]')
      assert_select('input#address_mobile_number[value="2"]')
      assert_select('input#address_email_address[value="x"]')
    end

    it "sets the address country as United Kingdom" do
      assert_select(
        "#address_country_id option[selected=selected]",
        text: uk.name
      )
    end
  end

  shared_examples_for "a customer details user" do
    context "without name, phone and email set in session" do
      let(:name) { "" }
      it { should redirect_to checkout_path }
    end
  end

  describe "GET billing" do
    let(:billing_address_id) { nil }

    context "with empty basket" do
      before { get :billing }
      it { should redirect_to basket_path }
    end

    context "with items in the basket" do
      let(:addresses) { [] }
      let(:name) { "n" }
      let(:phone) { "1" }
      let(:mobile) { "2" }
      let(:email) { "x" }

      before do
        add_items_to_basket
        session[:name] = name
        session[:phone] = phone
        session[:mobile] = mobile
        session[:email] = email
        session[:billing_address_id] = billing_address_id
        allow_any_instance_of(User).to receive(:addresses).and_return addresses
        get :billing
      end

      it_behaves_like "a customer details user"

      context "with existing billing address" do
        let(:billing_address) do
          FactoryBot.create(:address, address_line_1: "10 Downing St")
        end
        let(:billing_address_id) { billing_address.id }

        it { should respond_with(200) }

        it "populates the address form" do
          assert_select "input#address_address_line_1[value='10 Downing St']"
        end
      end

      context "with no existing billing address" do
        let(:billing_address_id) { nil }

        context "when user has addresses" do
          let(:addresses) { [Address.new] }

          it { should set_session[:source].to("billing") }
          it { should redirect_to choose_billing_address_addresses_path }
        end

        context "when user has no addresses" do
          it_behaves_like "an address prefiller"
        end
      end
    end
  end

  shared_examples_for "an address/user associator" do |method|
    let(:billing_address) { nil }
    let(:delivery_address) { nil }

    before do
      allow(controller).to receive(:current_user).and_return(current_user)
      allow(controller).to receive(:billing_address).and_return(billing_address)
      allow(controller).to receive(:delivery_address)
        .and_return(delivery_address)
      post method, params: {address: address.attributes}
    end

    context "when signed in" do
      let(:current_user) { FactoryBot.create(:user) }

      context "with new address" do
        let(:address) { FactoryBot.build(:address) }

        it "associates address with user" do
          expect(Address.last.user).to eq current_user
        end
      end

      context "with existing address" do
        let(:address) { FactoryBot.create(:address) }
        let(:billing_address) { address }
        let(:delivery_address) { address }

        it "associates address with user" do
          expect(address.reload.user).to eq current_user
        end
      end
    end
  end

  def attributes_to_save
    %w[
      address_line_1 address_line_2 address_line_3 company country_id county
      postcode town_city
    ].freeze
  end

  shared_examples_for "deliver_here checked" do
    context "when deliver_here checked" do
      let(:deliver_here) { "1" }

      context "when billing country is a shipping country" do
        let(:selected_country) do
          FactoryBot.create(
            :country, shipping_zone: FactoryBot.create(:shipping_zone)
          )
        end

        it "sets the session delivery_address_id to the billing address" do
          expect(session[:delivery_address_id]).to eq Address.last.id
        end

        it "redirects to delivery instructions" do
          expect(response).to redirect_to delivery_instructions_path
        end
      end

      context "when billing country is not a shipping country" do
        let(:selected_country) do
          FactoryBot.create(:country, shipping_zone: nil)
        end

        it "does not set the session delivery_address_id" do
          expect(session[:delivery_address_id]).to be_nil
        end

        it "redirects to billing" do
          expect(response).to redirect_to billing_details_path
        end

        it "sets a flash notice" do
          expect(flash[:notice]).to eq(
            I18n.t("controllers.checkout.save_billing.cannot_ship_to_country")
          )
        end
      end
    end
  end

  def create_collection_class
    FactoryBot.create(
      :shipping_class,
      name: "Collection", requires_delivery_address: false
    )
  end

  shared_examples_for "collection selected" do
    it "sets the shipping_class_id session var to that matching the " \
      "Collection class" do
      expect(session[:shipping_class_id]).to eq collection_class.id
    end

    it "updates the basket shipping_class_id to that matching the " \
      "Collection class" do
      expect(Basket.last.shipping_class_id).to eq collection_class.id
    end

    it "redirects to checkout confirmation" do
      expect(response).to redirect_to confirm_checkout_path
    end
  end

  describe "POST save_billing" do
    let(:selected_country) { FactoryBot.create(:country) }
    let(:address) do
      FactoryBot.build(:random_address, country: selected_country)
    end
    let(:billing_address) { nil }
    let(:collection) { nil }
    let(:deliver_here) { nil }
    let(:session_billing_address_id) { nil }
    let(:session_delivery_address_id) { nil }
    let(:mainland_uk) do
      FactoryBot.create(
        :shipping_class,
        name: "Mainland UK", requires_delivery_address: true
      )
    end
    let!(:collection_class) { create_collection_class }

    describe "specs where we call action first" do
      before do
        allow(controller).to receive(:billing_address).and_return(billing_address)
        post :save_billing, params: {
          address: address.attributes, deliver_here: deliver_here,
          collection: collection
        }, session: {
          billing_address_id: session_billing_address_id,
          delivery_address_id: session_delivery_address_id,
          shipping_class_id: mainland_uk.id,
          name: "Janey Humblestrum",
          email: "janey@humblestrum.com",
          mobile: "07777 123456",
          phone: "01234 567890"
        }
      end

      context "when billing address found" do
        let(:billing_address) { FactoryBot.create(:address) }

        it "updates the billing address" do
          expect(billing_address.reload.attributes.slice(*attributes_to_save))
            .to eq address.attributes.slice(*attributes_to_save)
        end

        it_behaves_like "deliver_here checked"

        context "when collection checked" do
          let(:collection) { "1" }

          it_behaves_like "collection selected"
        end
      end

      context "when updating and billing and delivery address are the same" do
        let(:billing_address) { FactoryBot.create(:address) }
        let(:session_billing_address_id) { billing_address.id }
        let(:session_delivery_address_id) { billing_address.id }

        it "makes a copy of the billing address" do
          expect(session[:billing_address_id]).to be
          expect(session[:billing_address_id]).to_not eq billing_address.id
        end
      end

      context "when billing address not found" do
        let(:billing_address) { nil }

        it "creates a new address" do
          expect(Address.find_by(address_line_1: address.address_line_1)).to be
        end

        it_behaves_like "deliver_here checked"

        it { should set_session[:billing_address_id] }
      end

      context "when create/update fails" do
        let(:address) { Address.new }
        it "redisplays the billing address form" do
          assert_select "h2", text: "Your billing address"
        end
      end
    end

    context "when create/update succeeds" do
      let(:params) { {address: FactoryBot.build(:address).attributes} }
      it_behaves_like("a checkout advancer", :post, :save_billing)

      it_behaves_like "an address/user associator", :save_billing
    end
  end

  describe "POST collect" do
    let!(:collection_class) { create_collection_class }

    before do
      post :collect
    end

    it_behaves_like "collection selected"
  end

  describe "GET delivery" do
    let(:delivery_address_id) { nil }

    context "with empty basket" do
      before { get :delivery }
      it { should redirect_to basket_path }
    end

    context "with items in the basket" do
      let(:addresses) { [] }
      let(:name) { "n" }
      let(:phone) { "1" }
      let(:mobile) { "2" }
      let(:email) { "x" }
      let!(:uk) { FactoryBot.create(:country, name: "United Kingdom") }

      before do
        add_items_to_basket
        session[:name] = name
        session[:phone] = phone
        session[:mobile] = mobile
        session[:email] = email
        session[:delivery_address_id] = delivery_address_id
        session[:delivery_postcode] = "DN1 2QP"
        allow_any_instance_of(User).to receive(:addresses).and_return addresses
        get :delivery
      end

      it_behaves_like "a customer details user"

      context "with existing delivery address" do
        let(:delivery_address) do
          FactoryBot.create(
            :address, address_line_1: "10 Downing St", postcode: "SW1A 2AA"
          )
        end
        let(:delivery_address_id) { delivery_address.id }

        it { should respond_with(200) }

        it "populates the address form" do
          assert_select "input#address_address_line_1[value='10 Downing St']"
          assert_select "input#address_postcode[value='SW1A 2AA']"
        end
      end

      context "with no existing delivery address" do
        let(:delivery_address_id) { nil }

        context "when user has addresses" do
          let(:addresses) { [Address.new] }

          it { should set_session[:source].to("delivery") }
          it { should redirect_to choose_delivery_address_addresses_path }
        end

        context "when user has no addresses" do
          it_behaves_like "an address prefiller"

          it "prefills the delivery postcode from the session" do
            assert_select "input#address_postcode[value='DN1 2QP']"
          end
        end
      end
    end
  end

  shared_examples_for "a delivery instructions updater" do |action|
    let(:address) { FactoryBot.build(:random_address) }

    it "records deliver options, except other, in delivery_instructions" do
      post action, params: {
        address: address.attributes, deliver_option: "Leave with neighbour"
      }
      expect(Basket.last.delivery_instructions).to eq "Leave with neighbour"
    end

    it "records custom other deliver instruction in delivery_instructions" do
      post action, params: {
        address: address.attributes, deliver_option: "Other",
        deliver_other: "Leave at unit 3"
      }
      expect(Basket.last.delivery_instructions).to eq "Leave at unit 3"
    end
  end

  describe "POST save_delivery" do
    let(:address) { FactoryBot.build(:random_address) }
    let(:delivery_address) { nil }
    let(:session_billing_address_id) { nil }
    let(:session_delivery_address_id) { nil }

    describe "specs where we call action first" do
      before do
        allow(controller).to receive(:delivery_address)
          .and_return(delivery_address)
        session[:billing_address_id] = session_billing_address_id
        session[:delivery_address_id] = session_delivery_address_id
        post :save_delivery, params: {address: address.attributes}
      end

      context "when delivery address found" do
        let(:delivery_address) { FactoryBot.create(:address) }

        it "updates the delivery address" do
          expect(delivery_address.reload.attributes.slice(*attributes_to_save))
            .to eq address.attributes.slice(*attributes_to_save)
        end
      end

      context "when updating and billing and delivery address are the same" do
        let(:delivery_address) { FactoryBot.create(:address) }
        let(:session_billing_address_id) { delivery_address.id }
        let(:session_delivery_address_id) { delivery_address.id }

        it "makes a copy of the delivery address" do
          expect(session[:delivery_address_id]).to be
          expect(session[:delivery_address_id]).to_not eq delivery_address.id
        end
      end

      context "when delivery address not found" do
        let(:delivery_address) { nil }

        it "creates a new address" do
          expect(Address.find_by(address_line_1: address.address_line_1)).to be
        end

        it { should set_session[:delivery_address_id] }
      end

      it_behaves_like "a delivery instructions updater", :save_delivery

      context "when create/update fails" do
        let(:address) { Address.new }
        it "re-displays the delivery address form" do
          assert_select "h2", text: "Your delivery address"
        end
      end
    end

    context "when create/update succeeds" do
      let(:params) { {address: FactoryBot.build(:address).attributes} }
      it_behaves_like("a checkout advancer", :post, :save_delivery)

      it_behaves_like "an address/user associator", :save_delivery
    end
  end

  describe "GET delivery_instructions" do
    it "renders a form to enter delivery instructions" do
      get :delivery_instructions
      assert_select(
        "form[action='#{save_delivery_instructions_path}']" \
        "[method=post]"
      )
    end
  end

  describe "POST save_delivery_instructions" do
    it_behaves_like(
      "a delivery instructions updater", :save_delivery_instructions
    )

    it "redirects to checkout" do
      post :save_delivery_instructions, params: {
        deliver_option: "Other", deliver_other: "Leave at unit 3"
      }
      expect(response).to redirect_to checkout_path
    end
  end

  describe "GET confirm" do
    let(:website) { Website.new(email: "merchant@example.com") }
    let(:valid_delivery_date) { true }

    before do
      allow(controller)
        .to receive(:valid_delivery_date?)
        .and_return(valid_delivery_date)
    end

    context "with empty basket" do
      before { get :confirm }

      it { should redirect_to basket_path }
    end

    context "with items in the basket and addresses set" do
      let(:billing_address) { FactoryBot.create(:address) }
      let(:delivery_address) { FactoryBot.create(:address) }
      let(:billing_address_id) { billing_address.try(:id) }
      let(:delivery_address_id) { delivery_address.try(:id) }
      let(:delivery_address_required?) { true }

      before do
        session[:billing_address_id] = billing_address_id
        session[:delivery_address_id] = delivery_address_id
        add_items_to_basket
        allow(controller).to receive(:delivery_address_required?)
          .and_return(delivery_address_required?)
      end

      it_behaves_like "a checker of updated baskets", :get, :confirm

      context "with invalid or missing (but required) delivery date" do
        let(:valid_delivery_date) { false }
        before { get :confirm }

        it { should redirect_to basket_path }
        it "sets a flash alert" do
          expect(flash[:alert]).to eq "Please choose a valid delivery date."
        end
      end

      it "prepares an order for payment" do
        expect(controller).to receive(:prepare_order_for_payment)
          .and_call_original
        get :confirm
      end

      it "displays customer details" do
        get :confirm, session: {
          name: "Alice", email: "alice@example.org", mobile: "07777 987654",
          phone: "01234 567890"
        }
        expect(response.body).to include("Alice")
        expect(response.body).to include("alice@example.org")
        expect(response.body).to include("01234 567890")
        expect(response.body).to include("07777 987654")
      end

      context "without a billing address" do
        before { get :confirm }
        let(:billing_address_id) { nil }
        it { should redirect_to checkout_path }
      end

      context "without a delivery address" do
        before { get :confirm }
        let(:delivery_address_id) { nil }
        context "but not required" do
          let(:delivery_address_required?) { false }
          it { should respond_with(200) }
        end
        context "but one is required" do
          it { should redirect_to checkout_path }
        end
      end

      it "sets :order_id as a signed cookied" do
        get :confirm
        expect(cookies.signed[:order_id]).to eq Order.last.id
      end

      context "without address" do
        before { get :confirm }
        context "billing" do
          let(:billing_address) { nil }
          it { should redirect_to checkout_path }
        end
        context "delivery" do
          let(:delivery_address) { nil }
          it { should redirect_to checkout_path }
        end
      end
    end
  end

  describe "#prepare_order_for_payment" do
    let(:billing_address) { FactoryBot.create(:address) }
    let(:delivery_address) { FactoryBot.create(:address) }
    let(:billing_address_id) { billing_address.try(:id) }
    let(:delivery_address_id) { delivery_address.try(:id) }

    before do
      session[:billing_address_id] = billing_address_id
      session[:delivery_address_id] = delivery_address_id
      add_items_to_basket
    end

    it "prepares an order for payment" do
      user = User.new
      allow(controller).to receive(:current_user).and_return(user)
      cookies.signed[:order_id] = 1234
      discount_lines = [double(DiscountLine)]
      allow(controller).to receive(:discount_lines).and_return(discount_lines)

      shipping_amount = 5.95
      shipping_vat_amount = 1.19
      shipping_method = "Super Express Parcel"
      shipping_quote_needed = true

      dispatch_date = Date.new(2017, 7, 3)
      delivery_date = Date.new(2017, 7, 4)

      delivery_address_required = [true, false].sample
      allow(controller).to receive(:delivery_address_required?)
        .and_return(delivery_address_required)

      allow(controller).to receive(:shipping_amount).and_return(shipping_amount)
      allow(controller).to receive(:shipping_vat_amount)
        .and_return(shipping_vat_amount)
      allow(controller).to receive(:shipping_method).and_return(shipping_method)
      allow(controller).to receive(:shipping_quote_needed?)
        .and_return(shipping_quote_needed)

      allow(controller).to receive(:dispatch_date).and_return(dispatch_date)
      allow(controller).to receive(:delivery_date).and_return(delivery_date)

      ob = double(Orders::OrderBuilder)
      expect(Orders::OrderBuilder)
        .to receive(:build)
        .with(1234)
        .and_yield(ob)
        .and_return(FactoryBot.build(:order))
      expect(ob).to receive(:add_client_details).with(
        ip_address: "0.0.0.0",
        user_agent: "Rails Testing"
      )
      expect(ob).to receive(:add_basket).with(@basket)
      expect(ob).to receive(:billing_address=).with(billing_address)
      expect(ob).to receive(:delivery_address=).with(delivery_address)
      expect(ob).to receive(:requires_delivery_address=)
        .with(delivery_address_required)
      expect(ob).to receive(:user=).with(user)
      expect(ob).to receive(:add_discount_lines).with(discount_lines)
      expect(ob).to receive(:add_shipping_details).with(
        net_amount: shipping_amount,
        vat_amount: shipping_vat_amount,
        method: shipping_method,
        # quote_needed should not be set to true at this stage as we don't want
        # to invalidate the basket; it is set later on when order placed
        quote_needed: false
      )
      expect(ob).to receive(:dispatch_date=).with(dispatch_date)
      expect(ob).to receive(:delivery_date=).with(delivery_date)

      controller.prepare_order_for_payment
    end

    it "updates the estimated delivery date" do
      order = instance_double(Order).as_null_object
      allow(Orders::OrderBuilder).to receive(:build).and_return(order)

      expect(order).to receive(:update_estimated_delivery_date)

      controller.prepare_order_for_payment
    end

    it "saves the order" do
      expect_any_instance_of(Order).to receive(:save!)
      controller.prepare_order_for_payment
    end
  end

  describe "#delivery_address_required?" do
    subject { controller.delivery_address_required? }
    before do
      allow(controller).to receive(:shipping_class).and_return(shipping_class)
    end
    context "shipping class is nil" do
      let(:shipping_class) { nil }
      it { should be_truthy }
    end
    context "shipping class requires delivery address" do
      let(:shipping_class) do
        FactoryBot.build(:shipping_class, requires_delivery_address: true)
      end
      it { should be_truthy }
    end
    context "shipping class does not require delivery address" do
      let(:shipping_class) do
        FactoryBot.build(:shipping_class, requires_delivery_address: false)
      end
      it { should be_falsey }
    end
  end

  describe "#shipping_method" do
    before do
      allow(controller).to receive(:shipping_class).and_return(shipping_class)
    end

    context "with a shipping class" do
      let(:shipping_class) do
        FactoryBot.create(:shipping_class, name: "Royal Mail")
      end

      it "records the shipping class name as the shipping method" do
        expect(controller.shipping_method).to eq "Royal Mail"
      end
    end

    context "without a shipping class" do
      let(:shipping_class) { nil }

      it 'records "Standard Shipping" as the shipping method' do
        expect(controller.shipping_method).to eq "Standard Shipping"
      end
    end
  end

  def add_items_to_basket
    @basket = FactoryBot.create(:basket)
    t_shirt = FactoryBot.create(:product)
    jeans = FactoryBot.create(:product)
    @basket.basket_items << FactoryBot.create(
      :basket_item, product: t_shirt, quantity: 2, basket_id: @basket.id
    )
    @basket.basket_items << FactoryBot.create(
      :basket_item, product: jeans, quantity: 1, basket_id: @basket.id
    )
    allow(controller).to receive(:basket).and_return(@basket)
  end
end
