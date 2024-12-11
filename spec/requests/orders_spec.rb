require "rails_helper"

RSpec.describe "Orders", type: :request do
  let(:current_user) { FactoryBot.create(:user) }

  describe "GET /orders" do
    context "with user" do
      before do
        allow_any_instance_of(OrdersController).to receive(:current_user).and_return(current_user)
      end

      it "assigns orders belonging to the current user to @orders" do
        expected_order = FactoryBot.create(:order, user: current_user)
        unexpected_order = FactoryBot.create(:order, user: FactoryBot.create(:user))
        get orders_path
        assert_select(
          ".order-number", text: "Order # #{expected_order.order_number}"
        )
        assert_select(
          ".order-number",
          text: "Order # #{unexpected_order.order_number}", count: 0
        )
      end
    end
  end

  describe "GET /orders/receipt" do
    context "when order is pay by phone" do
      let(:order) do
        double(
          Order,
          id: 1, payment_received?: false, payment_on_account?: false,
          quote?: false, pay_by_phone?: true, needs_shipping_quote?: false
        ).as_null_object
      end
      before do
        allow(Order).to receive(:find_by).with(id: order.id).and_return(order)
      end

      it "shows the receipt" do
        cookies = instance_double(
          ActionDispatch::Cookies::CookieJar, signed: {order_id: order.id}
        )
        allow_any_instance_of(OrdersController).to receive(:cookies).and_return(cookies)
        get "/orders/receipt"
        assert_select "h2", text: "Order Complete"
      end
    end

    context "when order needs shipping quote" do
      let(:order) do
        double(
          Order,
          id: 1, payment_received?: false, payment_on_account?: false,
          quote?: false, pay_by_phone?: false, needs_shipping_quote?: true
        ).as_null_object
      end
      before do
        allow(Order).to receive(:find_by).with(id: order.id).and_return(order)
      end

      it "shows the receipt" do
        cookies = instance_double(
          ActionDispatch::Cookies::CookieJar, signed: {order_id: order.id}
        )
        allow_any_instance_of(OrdersController).to receive(:cookies).and_return(cookies)
        get "/orders/receipt"
        assert_select "h2", text: "Order Complete"
      end
    end
  end

  describe "GET /orders/:id" do
    context "when signed in" do
      before do
        allow_any_instance_of(OrdersController).to receive(:current_user).and_return(current_user)
      end

      context "when order belongs to user" do
        let(:order) { Order.new(user_id: current_user.id) }
        before do
          allow(Order).to receive(:find_by).with(id: "1").and_return order
        end

        it "displays the order" do
          get "/orders/1"
          assert_select "h1", text: "Your Order"
        end
      end

      context "when order belongs to someone else" do
        before do
          order = Order.new(user_id: 0)
          allow(Order).to receive(:find_by).with(id: "1").and_return order
        end

        it "redirects the user to the home page" do
          get "/orders/1"
          expect(response).to redirect_to root_path
        end

        it "sets a notice" do
          get "/orders/1"
          expect(flash[:notice]).to eq I18n.t("controllers.orders.show.no_permission")
        end
      end
    end
  end

  describe "GET /orders/:id/invoice" do
    it "finds the order" do
      expect(Order).to receive(:find_by)
      get "/orders/1/invoice"
    end

    context "when the order is not found" do
      it "redirects to the orders page" do
        get "/orders/1/invoice"
        expect(response).to redirect_to(orders_path)
      end
    end

    context "when the order is found" do
      let(:order) {
        instance_double(
          Order,
          paperwork_type: "Sales Invoice",
          invoiced_at: Time.current,
          order_lines: [],
          payments: [],
          line_total_net: BigDecimal("123.45"),
          vat_total: BigDecimal("23.45"),
          total: BigDecimal("146.90")
        ).as_null_object
      }

      before do
        allow(Order).to receive(:find_by).and_return(order)
      end

      it "requires a user" do
        get "/orders/1/invoice"
        expect(response).to redirect_to(sign_in_path)
      end

      context "with a user" do
        before { allow_any_instance_of(OrdersController).to receive(:logged_in?).and_return(true) }

        context "when the user can access the order" do
          before do
            allow_any_instance_of(OrdersController).to receive(:can_access_order?).and_return(true)
          end

          context "when the order is an invoice" do
            before { allow(order).to receive(:invoice?).and_return(true) }
            it "renders the invoice" do
              get "/orders/1/invoice"
              assert_select "h1", text: "Sales Invoice"
            end
          end

          context "when the order is not an invoice" do
            before { allow(order).to receive(:invoice?).and_return(false) }
            it "redirects to the orders page" do
              get "/orders/1/invoice"
              expect(response).to redirect_to(orders_path)
            end
          end
        end

        it "redirects to sign in when the user cannot access the order" do
          allow_any_instance_of(OrdersController).to receive(:can_access_order?).and_return(false)
          get "/orders/1/invoice"
          expect(response).to redirect_to(new_customer_session_path)
        end
      end
    end

    context "format is pdf" do
      let(:order) { FactoryBot.create(:order) }
      before do
        allow_any_instance_of(OrdersController).to receive(:logged_in?).and_return(true)
        allow_any_instance_of(OrdersController).to receive(:can_access_order?).and_return(true)
        allow_any_instance_of(Order).to receive(:invoice?).and_return(true)
      end

      it "generates and sends an invoice PDF" do
        invoice = double(PDF::Invoice)
        expect(PDF::Invoice).to receive(:new).and_return(invoice)
        expect(invoice).to receive(:generate)
        expect(invoice).to receive(:filename).and_return File.join(["spec", "fixtures", "pdf", "fake.pdf"])
        get "/orders/#{order.id}/invoice", params: {}, headers: {"Accept" => "application/pdf"}
      end
    end
  end

  describe "POST /orders/opt_in" do
    it "sets current order user's opt in when opt_in = 1" do
      order = FactoryBot.create(:order, user: FactoryBot.create(:user, opt_in: false))
      expect_any_instance_of(OrdersController)
        .to receive(:cookies)
        .and_return(double(signed: {order_id: order.id}))
      post "/orders/opt_in", params: {opt_in: "1"}
      expect(order.reload.user.opt_in).to be
    end

    it "clears current order user's opt in when opt_in = 0" do
      user = FactoryBot.create(:user, opt_in: true, explicit_opt_in_at: Date.current)
      order = FactoryBot.create(:order, email_address: user.email, user: user)
      expect_any_instance_of(OrdersController)
        .to receive(:cookies)
        .and_return(double(signed: {order_id: order.id}))
      post "/orders/opt_in", params: {opt_in: "0"}
      user.reload
      expect(user.opt_in).to be_falsey
      expect(user.explicit_opt_in_at).to be_nil
    end
  end

  describe "POST request_shipping_quote" do
    let(:order) { FactoryBot.create(:order) }

    before do
      cookies = instance_double(
        ActionDispatch::Cookies::CookieJar, signed: {order_id: order.id}
      )
      allow_any_instance_of(OrdersController).to receive(:cookies).and_return(cookies)
      post "/orders/request_shipping_quote"
    end

    it "sets the status of the order to NEEDS_SHIPPING_QUOTE" do
      expect(order.reload.needs_shipping_quote?).to be_truthy
    end

    it "redirects the customer to the receipt page" do
      expect(response).to redirect_to receipt_orders_path
    end

    it "sets a flash notice" do
      expect(flash[:notice])
        .to eq I18n.t("controllers.orders.request_shipping_quote.what_next")
    end
  end

  describe "GET /orders/:id/track" do
    let(:order) { FactoryBot.create(:order, delivery_postcode: "DN1 2QP") }
    def perform
      get "/orders/#{order.id}/track", params: {t: token}
    end

    context "when token incorrect" do
      let(:token) { "bad" }

      it "redirects to home page" do
        perform
        expect(response).to redirect_to root_path
        expect(flash[:alert]).to eq "That link is invalid."
      end
    end

    context "when token correct" do
      let(:token) { order.token }

      it "renders shipping details with links to courier tracking URLs" do
        rm = FactoryBot.create(:courier, name: "Royal Mail", tracking_url: "https://royalmail.example.com/{{consignment}}/{{postcode}}")
        ups = FactoryBot.create(:courier, name: "UPS", tracking_url: "https://ups.example.com/{{consignment}}/{{postcode}}")
        FactoryBot.create(:shipment, order: order, shipped_at: nil, courier: rm, consignment_number: "D1234567")
        FactoryBot.create(:shipment, order: order, shipped_at: Time.current, courier: ups, partial: true, consignment_number: "L7777777")
        FactoryBot.create(:shipment, order: order, shipped_at: Time.current, courier: ups, partial: false, consignment_number: "L8888888")
        perform
        expect(response.status).to eq 200
        assert_select "a[href='https://ups.example.com/L7777777/DN12QP']"
        assert_select "a[href='https://ups.example.com/L8888888/DN12QP']"
        assert_select "a[href='https://rm.example.com/D1234567/DN12QP']", count: 0
      end
    end
  end
end
