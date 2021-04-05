# frozen_string_literal: true

module Orders
  class OrderBuilder
    attr_reader :order

    def self.build(order_id)
      builder = new(order_id)
      yield builder

      builder.prepare_for_payment
      builder.order
    end

    delegate :administrator=, to: :order
    delegate :delivery_date=, to: :order
    delegate :dispatch_date=, to: :order
    delegate :requires_delivery_address=, to: :order

    def initialize(order_id)
      @order = Orders::Recycler.new_or_recycled(order_id)
    end

    def add_basket(basket)
      @order.add_basket(basket) if basket
    end

    def add_discount_lines(discount_lines)
      @order.add_discount_lines(discount_lines)
      discount_lines.map(&:discount).uniq.each do |discount|
        @order.discount_uses << DiscountUse.new(discount: discount)
      end
    end

    def billing_address=(address)
      @order.copy_billing_address(address) if address
    end

    def delivery_address=(address)
      @order.copy_delivery_address(address) if address
    end

    def add_shipping_details(net_amount:, vat_amount:, method:, quote_needed:)
      order.shipping_amount = net_amount
      order.shipping_vat_amount = vat_amount
      order.shipping_method = method
      order.status = Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE if quote_needed
    end

    def add_client_details(ip_address:, user_agent:, platform: "web")
      Client.update(
        order, platform: platform, ip_address: ip_address, user_agent: user_agent
      )
    end

    def prepare_for_payment
      return if order.needs_shipping_quote?
      @order.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
    end

    def user=(user)
      order.user = user
      order.logged_in = user ? user.persisted? : false
    end
  end
end
