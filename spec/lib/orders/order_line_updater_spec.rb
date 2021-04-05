# frozen_string_literal: true

require "rails_helper"

module Orders
  RSpec.describe OrderLineUpdater do
    let(:order) { FactoryBot.create(:order) }
    let(:line) { OrderLine.new(order: order) }
    let(:product) { FactoryBot.create(:product) }
    let(:admin) { "Alice" }
    let(:updater) do
      OrderLineUpdater.new(
        administrator: admin,
        order_line: line,
        feature_descriptions: "fd",
        product_brand: "brand",
        product_id: product.id,
        product_name: "pn",
        product_price: 1.23,
        product_sku: product.sku,
        product_weight: 2.34,
        quantity: 2,
        vat_percentage: 20
      )
    end

    describe "#initialize" do
      it "updates attributes of the order line" do
        updater
        ol = updater.order_line
        expect(ol.feature_descriptions).to eq "fd"
        expect(ol.product_brand).to eq "brand"
        expect(ol.product_id).to eq product.id
        expect(ol.product_name).to eq "pn"
        expect(ol.product_price).to eq 1.23
        expect(ol.product_sku).to eq product.sku
        expect(ol.product_weight).to eq 2.34
        expect(ol.quantity).to eq 2
        expect(ol.vat_percentage).to eq 20
      end
    end

    describe "#save" do
      it "saves the order line" do
        expect(line).to receive(:save)
        updater.save
      end

      it "adds an order comment" do
        updater.save
        expect(order.order_comments.last.comment).to eq(
          "Line (#{line}) updated by Alice"
        )
      end

      it "only adds an order comment when the order line is changed" do
        updater.save
        updater.save
        expect(order.order_comments.count).to eq 1
      end
    end
  end
end
