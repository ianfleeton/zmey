require "rails_helper"
require_relative "shared_examples/api_pagination"

describe "Admin orders API" do
  before do
    prepare_api_website
  end

  describe "GET index" do
    let(:json) { JSON.parse(response.body) }
    let(:num_items) { 1 }
    let(:order_number) { nil }
    let(:page) { nil }
    let(:page_size) { nil }
    let(:processed) { nil }
    let(:status) { nil }
    let(:default_page_size) { 3 }

    # +more_setup+ lambda allows more setup in the outer before block.
    let(:more_setup) { nil }

    before do
      # Reduce default page size for spec execution speed.
      allow_any_instance_of(Api::Admin::OrdersController)
        .to receive(:default_page_size)
        .and_return(default_page_size)

      num_items.times do |x|
        FactoryBot.create(
          :order,
          :unpaid,
          user_id: FactoryBot.create(:user).id,
          created_at: Date.today - x.days # affects ordering
        )
      end
      @order1 = Order.first

      more_setup.try(:call)

      get "/api/admin/orders", params: {
        order_number: order_number,
        page: page, page_size: page_size,
        processed: processed, status: status
      }
    end

    it "returns all orders" do
      expect(json["orders"].length).to eq 1
      order = json["orders"][0]
      expect(order["id"]).to eq @order1.id
      expect(order["href"]).to eq api_admin_order_url(@order1)
      expect(order["order_number"]).to eq @order1.order_number
      user = order["user"]
      expect(user["id"]).to eq @order1.user.id
      expect(user["href"]).to eq api_admin_user_url(@order1.user)
      expect(order["email_address"]).to eq @order1.email_address
      expect(order["total"]).to eq @order1.total.to_s
      expect(order["status"]).to eq Enums::PaymentStatus.new(@order1.status).to_api
    end

    it "returns 200 OK" do
      expect(response.status).to eq 200
    end

    context "with order_number set" do
      let(:order_number) { SecureRandom.hex }

      let!(:more_setup) {
        -> {
          @matching_order = FactoryBot.create(:order, :unpaid)
          @matching_order.order_number = order_number
          @matching_order.save
        }
      }

      it "returns the matching order" do
        expect(json["orders"].length).to eq 1
        expect(json["orders"][0]["order_number"]).to eq @matching_order.order_number
      end
    end

    context "with status filtered to waiting_for_payment" do
      let(:status) { "waiting_for_payment" }

      it "returns 1 order" do
        expect(json["orders"].length).to eq 1
      end
    end

    context "with status filtered to payment_received" do
      let(:status) { "payment_received" }

      it "returns 0 orders" do
        expect(json["orders"].length).to eq 0
      end
    end

    context "with status filtered to payment_received|waiting_for_payment" do
      let(:status) { "payment_received|waiting_for_payment" }

      it "returns 1 order" do
        expect(json["orders"].length).to eq 1
      end
    end

    context "with processed set" do
      let!(:more_setup) {
        -> {
          @processed_order = FactoryBot.create(:order,
            processed_at: Date.today - 1.day)
        }
      }

      context "to true" do
        let(:processed) { true }

        it "returns processed orders only" do
          expect(json["orders"].length).to eq 1
          expect(json["orders"][0]["id"]).to eq @processed_order.id
        end
      end

      context "to false" do
        let(:processed) { false }

        it "returns unprocessed orders only" do
          expect(json["orders"].length).to eq 1
          expect(json["orders"][0]["id"]).to eq Order.first.id
        end
      end
    end

    it_behaves_like "an API paginator", class: Order

    context "with no orders" do
      let(:num_items) { 0 }

      it "returns 200 OK" do
        expect(response.status).to eq 200
      end

      it "returns an empty set" do
        expect(json["orders"].length).to eq 0
      end
    end
  end

  describe "GET show" do
    let(:order) { JSON.parse(response.body)["order"] }

    context "when order found" do
      before do
        @order = FactoryBot.create(:order,
          billing_company: "YESL", billing_address_line_3: "Copley Road",
          customer_note: "Please gift wrap my order",
          delivery_company: "FBS", delivery_address_line_3: "Beighton",
          delivery_instructions: "Leave in the dog kennel. He won't bite.",
          po_number: "PO123",
          shipment_email_sent_at: "2014-05-14T16:25:56.000+01:00",
          shipped_at: "2014-05-14T15:50:12.000+01:00")
      end

      it "returns 200 OK" do
        get api_admin_order_path(@order)
        expect(response.status).to eq 200
      end

      ["billing_address_line_3", "billing_company",
        "customer_note",
        "delivery_address_line_3", "delivery_company",
        "delivery_instructions",
        "po_number",
        "weight"].each do |component|
        it "includes #{component} in JSON" do
          get api_admin_order_path(@order)
          expect(order[component]).to eq @order.send(component.to_sym)
        end
      end

      ["shipment_email_sent_at", "shipped_at"].each do |component|
        it "includes datetime component #{component} in JSON" do
          get api_admin_order_path(@order)
          expect(Time.parse(order[component])).to eq @order.send(component.to_sym)
        end
      end

      context "with order lines" do
        before do
          @order_line = FactoryBot.create(:order_line, order: @order, product_price: 1.23, product_rrp: 2.34)
          get api_admin_order_path(@order)
        end

        it "has 1 order line" do
          expect(order["order_lines"].length).to eq 1
        end

        describe "first order line" do
          subject { order["order_lines"][0] }

          it "includes line_total_net" do
            expect(subject["line_total_net"]).to eq @order_line.line_total_net.to_s
          end

          it "includes product_rrp" do
            expect(subject["product_rrp"]).to eq @order_line.product_rrp.to_s
          end

          it "includes quantity" do
            expect(subject["quantity"]).to eq @order_line.quantity.to_s
          end
        end
      end

      context "with order comments" do
        before do
          @order_comment = FactoryBot.create(:order_comment, order: @order, comment: "Comment")
          get api_admin_order_path(@order)
        end

        it "has 1 order comment" do
          expect(order["order_comments"].length).to eq 1
        end

        describe "first order comment" do
          subject { order["order_comments"][0] }

          it "includes the comment" do
            expect(subject["comment"]).to eq @order_comment.comment
          end
        end
      end
    end

    context "when no order" do
      it "returns 404 Not Found" do
        get "/api/admin/orders/0"
        expect(response.status).to eq 404
      end
    end
  end

  describe "POST create" do
    let(:country) { FactoryBot.create(:country) }
    let(:billing_company) { SecureRandom.hex }
    let(:billing_address_line_1) { SecureRandom.hex }
    let(:billing_address_line_3) { SecureRandom.hex }
    let(:billing_country_id) { country.id }
    let(:billing_county) { SecureRandom.hex }
    let(:billing_postcode) { SecureRandom.hex }
    let(:billing_town_city) { SecureRandom.hex }
    let(:delivery_company) { SecureRandom.hex }
    let(:delivery_address_line_1) { SecureRandom.hex }
    let(:delivery_address_line_3) { SecureRandom.hex }
    let(:delivery_country_id) { country.id }
    let(:delivery_county) { SecureRandom.hex }
    let(:delivery_instructions) { SecureRandom.hex }
    let(:delivery_postcode) { SecureRandom.hex }
    let(:delivery_town_city) { SecureRandom.hex }
    let(:email_address) { "#{SecureRandom.hex}@example.org" }
    let(:order_number) { "ORDER123456" }
    let(:payment_status) { "payment_received" }
    let(:po_number) { "PO123" }
    let(:processed_at) { "2015-03-05T10:00:00.000+00:00" }

    let(:basic_params) {
      {
        billing_company: billing_company,
        billing_address_line_1: billing_address_line_1,
        billing_address_line_3: billing_address_line_3,
        billing_country_id: billing_country_id,
        billing_county: billing_county,
        billing_postcode: billing_postcode,
        billing_town_city: billing_town_city,
        delivery_company: delivery_company,
        delivery_address_line_1: delivery_address_line_1,
        delivery_address_line_3: delivery_address_line_3,
        delivery_country_id: delivery_country_id,
        delivery_county: delivery_county,
        delivery_instructions: delivery_instructions,
        delivery_postcode: delivery_postcode,
        delivery_town_city: delivery_town_city,
        email_address: email_address,
        order_number: order_number,
        po_number: po_number,
        processed_at: processed_at,
        status: payment_status
      }
    }

    it "inserts a new order into the website" do
      post "/api/admin/orders", params: {order: basic_params}
      o = Order.last
      expect(o.billing_address_line_1).to eq billing_address_line_1
      expect(o.billing_address_line_3).to eq billing_address_line_3
      expect(o.billing_company).to eq billing_company
      expect(o.billing_country).to eq country
      expect(o.billing_postcode).to eq billing_postcode
      expect(o.billing_town_city).to eq billing_town_city
      expect(o.delivery_address_line_1).to eq delivery_address_line_1
      expect(o.delivery_address_line_3).to eq delivery_address_line_3
      expect(o.delivery_company).to eq delivery_company
      expect(o.delivery_country).to eq country
      expect(o.delivery_postcode).to eq delivery_postcode
      expect(o.delivery_town_city).to eq delivery_town_city
      expect(o.email_address).to eq email_address
      expect(o.order_number).to eq order_number
      expect(o.po_number).to eq po_number
      expect(o.processed_at).to eq "2015-03-05 10:00:00"
      expect(o.status).to eq Enums::PaymentStatus::PAYMENT_RECEIVED
    end

    it "ignores a blank status" do
      post "/api/admin/orders", params: {order: basic_params.merge(status: "")}
    end

    it "returns 422 if order cannot be created" do
      post "/api/admin/orders", params: {order: {email_address: "is not enough"}}
      expect(status).to eq 422
    end

    it "accepts billing_country_name in place of billing_country_id" do
      basic_params[:billing_country_name] = country.name
      basic_params.delete(:billing_country_id)
      post "/api/admin/orders", params: {order: basic_params}
      expect(Order.last.billing_country).to eq country
    end

    it "accepts delivery_country_name in place of delivery_country_id" do
      basic_params[:delivery_country_name] = country.name
      basic_params.delete(:delivery_country_id)
      post "/api/admin/orders", params: {order: basic_params}
      expect(Order.last.delivery_country).to eq country
    end
  end

  describe "DELETE delete_all" do
    it "deletes all orders in the website" do
      order_1 = FactoryBot.create(:order)
      order_2 = FactoryBot.create(:order)

      delete "/api/admin/orders"

      expect(Order.find_by(id: order_1.id)).not_to be
      expect(Order.find_by(id: order_2.id)).not_to be
    end

    it "responds with 204 No Content" do
      delete "/api/admin/orders"

      expect(status).to eq 204
    end
  end

  describe "PATCH update" do
    let(:processed_at) { "2014-05-14T14:03:56.000+01:00" }
    let(:shipment_email_sent_at) { "2014-05-14T16:25:56.000+01:00" }
    let(:shipped_at) { "2014-05-14T15:50:12.000+01:00" }
    let(:payment_status) { "payment_received" }

    let(:basic_params) {
      {
        processed_at: processed_at,
        shipment_email_sent_at: shipment_email_sent_at,
        shipped_at: shipped_at,
        status: payment_status
      }
    }

    before do
      patch api_admin_order_path(order), params: {order: basic_params}
    end

    context "when order found" do
      let(:order) { FactoryBot.create(:order) }

      it "responds with 204 No Content" do
        expect(status).to eq 204
      end

      it "updates an order" do
        order.reload
        expect(Order.find_by(
          basic_params.merge(
            processed_at: "2014-05-14 13:03:56",
            shipment_email_sent_at: "2014-05-14 15:25:56",
            shipped_at: "2014-05-14 14:50:12",
            status: Enums::PaymentStatus::PAYMENT_RECEIVED
          )
        )).to eq order
      end
    end

    context "when order not found" do
      let(:order) do
        o = FactoryBot.create(:order)
        o.id += 1
        o
      end

      it "responds 404 Not Found" do
        expect(status).to eq 404
      end
    end
  end
end
