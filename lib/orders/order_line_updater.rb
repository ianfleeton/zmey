# frozen_string_literal: true

module Orders
  # Aids admin updating of order lines.
  class OrderLineUpdater
    attr_reader :order_line

    def initialize(
      administrator:,
      order_line:, feature_descriptions:, product_brand:, product_id:, product_name:,
      product_price:, product_sku:, product_weight:, quantity:, tax_percentage:
    )
      @administrator = administrator
      @order_line = order_line
      order_line.product_brand = product_brand
      order_line.product_id = product_id
      order_line.product_name = product_name
      order_line.product_sku = product_sku
      order_line.product_weight = product_weight
      order_line.quantity = quantity
      order_line.feature_descriptions = feature_descriptions

      update_product_price(product_price)
      update_tax(tax_percentage)
    end

    def save
      if order_line.changed?
        order_line.save
        order_line.order.order_comments << OrderComment.new(
          comment: "Line (#{order_line}) updated by #{@administrator}"
        )
      end
    end

    private

    def update_product_price(new_price)
      # Prevent AR change being recorded unnecessarily.
      return if order_line.product_price == new_price.to_f
      order_line.product_price = new_price.to_f
    end

    def update_tax(tax_percentage)
      return unless order_line.changed? || tax_changed?(tax_percentage)
      order_line.tax_amount = tax_amount(tax_percentage)
    end

    def tax_changed?(new_tax)
      # Use three decimal places and ignore changes to a higher precision.
      original_tax_percentage.round(3) != new_tax.to_f.round(3)
    end

    def original_tax_percentage
      order_line.tax_percentage
    end

    # Calculates the tax amount for <tt>order_line</tt> when the tax rate is
    # <tt>percentage</tt>%.
    def tax_amount(percentage)
      percentage.to_f / 100.0 * order_line.line_total_net if order_line.valid?
    end
  end
end
