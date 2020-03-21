require "rails_helper"

module Admin
  RSpec.describe OrdersController, type: :controller do
    def mock_order(stubs = {})
      @mock_order ||= double(Order, stubs)
    end

    context "when admin or manager" do
      before { allow(controller).to receive(:admin_or_manager?).and_return(true) }

      describe "POST create" do
        let(:country) { FactoryBot.create(:country) }
        let(:params) {
          {
            billing_company: "Billing Company",
            billing_country_id: country.id.to_s,
            billing_full_name: "A Buyer",
            billing_phone_number: "01234 567890",
            delivery_company: "Delivery Company",
            delivery_country_id: country.id.to_s,
            delivery_full_name: "A Recipient",
            delivery_phone_number: "01234 567890",
            email_address: "shopper@example.org"
          }
        }
        let(:order) { FactoryBot.build(:order, params) }

        it "creates an order" do
          post :create, params: {order: order.attributes}
          expect(Order.find_by(params)).to be
        end

        it "sets the order status to WAITING_FOR_PAYMENT" do
          post :create, params: {order: order.attributes}
          expect(Order.last.status).to eq Enums::PaymentStatus::WAITING_FOR_PAYMENT
        end

        context "when save succeeds" do
          before do
            allow_any_instance_of(Order).to receive(:save).and_return(true)
          end

          it "redirects to the admin orders page" do
            post :create, params: {order: order.attributes}
            expect(response).to redirect_to admin_orders_path
          end
        end
      end

      describe "PATCH update" do
        let(:order) { FactoryBot.create(:order) }
        let(:po_number) { "PO123" }
        let(:shipped_at) { Time.zone.now }
        let(:shipping_tracking_number) { "TRACK123" }
        let(:order_params) {
          {
            order_number: order.order_number,
            po_number: po_number,
            shipped_at: shipped_at,
            shipping_tracking_number: shipping_tracking_number
          }
        }
        let(:pre) { nil }

        let(:order_line_product_name) { nil }
        let(:order_line_product_price) { nil }
        let(:order_line_product_sku) { nil }
        let(:order_line_product_weight) { nil }
        let(:order_line_quantity) { nil }
        let(:order_line_tax_percentage) { nil }

        before do
          pre.try(:call)
          patch :update, params: {
            id: order.id,
            order: order_params,
            order_line_product_name: order_line_product_name,
            order_line_product_price: order_line_product_price,
            order_line_product_sku: order_line_product_sku,
            order_line_product_weight: order_line_product_weight,
            order_line_quantity: order_line_quantity,
            order_line_tax_percentage: order_line_tax_percentage
          }
        end

        it "redirects to the edit order page" do
          expect(response).to redirect_to edit_admin_order_path(order)
        end

        it "updates order details" do
          order.reload
          expect(order.po_number).to eq po_number
          expect(order.shipped_at).to be_within(1.second).of(shipped_at)
          expect(order.shipping_tracking_number).to eq shipping_tracking_number
        end

        def lock_order
          allow_any_instance_of(Order).to receive(:locked?).and_return(true)
        end

        context "when order locked" do
          let(:pre) { -> { lock_order } }

          it "does not update many order details" do
            expect(order.reload.po_number).to be_nil
          end

          it "does update some details" do
            order.reload
            expect(order.shipped_at).to be_within(1.second).of(shipped_at)
            expect(order.shipping_tracking_number).to eq shipping_tracking_number
          end
        end

        context "with new order lines" do
          let(:sku) { "SKU" }
          let(:order_line_product_name) { {"-1" => "A", "-2" => "B"} }
          let(:order_line_product_price) { {"-1" => "3", "-2" => "7"} }
          let(:order_line_product_sku) { {"-1" => sku, "-2" => "Z"} }
          let(:order_line_product_weight) { {"-1" => "1", "-2" => "3"} }
          let(:order_line_quantity) { {"-1" => "1", "-2" => "2"} }
          let(:order_line_tax_percentage) { {"-1" => "15", "-2" => "20"} }

          it "adds new order lines" do
            expect(order.reload.order_lines.count).to eq 2
          end

          it "records SKUs" do
            expect(order.reload.order_lines.first.product_sku).to eq sku
          end

          context "when order locked" do
            let(:pre) { -> { lock_order } }
            it "does not add new lines" do
              expect(order.reload.order_lines.count).to eq 0
            end
          end
        end

        context "with existing order lines" do
          let(:sku) { "SKU" }
          let(:order_line) { FactoryBot.create(:order_line, order: order, product_weight: 1, quantity: 1) }
          let(:order_line_product_name) { {order_line.id => "New name"} }
          let(:order_line_product_price) { {order_line.id => 3.21} }
          let(:order_line_product_sku) { {order_line.id => sku} }
          let(:order_line_product_weight) { {order_line.id => 2} }
          let(:order_line_quantity) { {order_line.id => 3} }
          let(:order_line_tax_percentage) { {order_line.id => 20} }

          it "updates the order line" do
            order_line.reload
            expect(order_line.product_name).to eq "New name"
            expect(order_line.product_price).to eq 3.21
            expect(order_line.product_weight).to eq 2
            expect(order_line.quantity).to eq 3
          end

          it "updates SKUs" do
            order_line.reload
            expect(order_line.product_sku).to eq sku
          end

          context "when order locked" do
            let(:pre) { -> { lock_order } }
            it "does not update the order line" do
              order_line.reload
              expect(order_line.product_name).not_to eq "New name"
            end
          end
        end
      end

      describe "GET purge_old_unpaid" do
        it "purges old unpaid orders" do
          expect(Order).to receive(:purge_old_unpaid)
          get "purge_old_unpaid"
        end

        it "redirects to admin orders" do
          get "purge_old_unpaid"
          expect(response).to redirect_to(admin_orders_path)
        end
      end

      describe "POST destroy" do
        it "finds the order" do
          expect(Order).to receive(:find_by).with(id: "1")
          post_destroy
        end

        context "when order is found" do
          before { allow(Order).to receive(:find_by).and_return(mock_order) }

          it "destroys the order" do
            expect(mock_order).to receive(:destroy)
            post_destroy
          end

          it "redirects to admin orders" do
            allow(mock_order).to receive(:destroy)
            post_destroy
            expect(response).to redirect_to(admin_orders_path)
          end
        end

        def post_destroy
          post "destroy", params: {id: "1"}
        end
      end

      describe "POST mark_processed" do
        let(:order) { FactoryBot.create(:order, processed_at: nil) }

        before { post "mark_processed", params: {id: order.id} }

        it "sets the order processed_at to current time" do
          expect(order.reload.processed_at).to be
        end

        it "sets a flash notice" do
          expect(flash[:notice]).to eq I18n.t("controllers.admin.orders.mark_processed.marked")
        end

        it "redirects to #edit" do
          expect(response).to redirect_to edit_admin_order_path(order)
        end
      end

      describe "POST mark_unprocessed" do
        let(:order) { FactoryBot.create(:order, processed_at: Time.zone.now) }

        before { post "mark_unprocessed", params: {id: order.id} }

        it "sets the order processed_at to nil" do
          expect(order.reload.processed_at).to be_nil
        end

        it "sets a flash notice" do
          expect(flash[:notice]).to eq I18n.t("controllers.admin.orders.mark_unprocessed.marked")
        end

        it "redirects to #edit" do
          expect(response).to redirect_to edit_admin_order_path(order)
        end
      end
    end
  end
end
