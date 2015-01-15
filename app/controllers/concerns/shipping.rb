module Shipping
  extend ActiveSupport::Concern

  protected

    # Returns the customer's delivery address or <tt>nil</tt> if the customer
    # has not yet entered one.
    def delivery_address
      @delivery_address ||= Address.find_by(id: session[:delivery_address_id])
    end

    def set_shipping_class
      @shipping_class = ShippingClass.find_by(session[:shipping_class_id])
    end

    # Calculates shipping amount based on the global website shipping amount
    # and whether shipping is applicable to any products in the basket.
    #
    # Returns +nil+ by default if there is no shipping amount.
    # Set +return_if_nil+ to 0, for example, if using in a calculation.
    def shipping_amount(return_if_nil=nil)
      amount = 0.0

      if basket.apply_shipping?
        amount = website.shipping_amount
        amount_by_address = calculate_shipping_from_address(delivery_address)
        amount = amount_by_address.nil? ? amount : amount_by_address
      end

      amount += basket.shipping_supplement

      (amount == 0.0) ? return_if_nil : amount
    end

    def shipping_tax_amount(shipping_amount_net)
      if shipping_amount_net && website.vat_number.present?
        Product::VAT_RATE * shipping_amount_net
      else
        0
      end
    end

    def calculate_shipping_from_address(address)
      if !address
        nil
      elsif !address.country
        nil
      elsif !address.country.shipping_zone
        nil
      elsif address.country.shipping_zone.shipping_classes.empty?
        nil
      else
        calculate_shipping_from_class(address.country.shipping_zone.shipping_classes.first)
      end
    end

    def calculate_shipping_from_class(shipping_class)
      case shipping_class.table_rate_method
      when 'basket_total'
        value = @basket.total(true)
      when 'weight'
        value = @basket.weight
      else
        raise 'Unknown table rate method'
      end

      shipping = nil

      unless shipping_class.shipping_table_rows.empty?
        shipping_class.shipping_table_rows.each do |row|
          if value >= row.trigger_value
            shipping = row.amount
          end
        end
      end

      shipping
    end
end
