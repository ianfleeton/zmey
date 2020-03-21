module YorkshirePayments
  class FieldList
    def initialize(order:, merchant_id:, pre_shared_key:, callback_url:, redirect_url:)
      @order = order
      @merchant_id = merchant_id
      @pre_shared_key = pre_shared_key
      @callback_url = callback_url
      @redirect_url = redirect_url
    end

    def fields
      if @pre_shared_key.present?
        base_fields << ["signature", signature]
      else
        base_fields
      end
    end

    def signature
      Signature.new(base_fields, @pre_shared_key).sign
    end

    private

    def base_fields
      @base_fields ||= [
        ["amount", amount],
        ["callbackURL", @callback_url],
        ["countryCode", "826"],
        ["currencyCode", "826"],
        ["customerAddress", "#{@order.billing_address_line_1}\n#{@order.billing_town_city}\n#{@order.billing_county}"],
        ["customerEmail", @order.email_address],
        ["customerName", @order.billing_full_name],
        ["customerPhone", @order.billing_phone_number],
        ["customerPostCode", @order.billing_postcode],
        ["merchantID", @merchant_id],
        ["redirectURL", @redirect_url],
        ["transactionUnique", @order.order_number]
      ]
    end

    def amount
      (@order.total * 100).round.to_s
    end
  end
end
