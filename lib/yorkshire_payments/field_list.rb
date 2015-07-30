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
        base_fields << ['signature', signature]
      else
        base_fields
      end
    end

    def signature
      Digest::SHA512.hexdigest(base_fields_query + @pre_shared_key)
    end

    private

      def base_fields
        @base_fields ||= [
          ['amount', amount],
          ['callbackURL', @callback_url],
          ['countryCode', '826'],
          ['currencyCode', '826'],
          ['merchantID', @merchant_id],
          ['redirectURL', @redirect_url],
          ['transactionUnique', @order.order_number],
        ]
      end

      def base_fields_query
        base_fields.map {|k,v| "#{k}=#{CGI.escape(v)}"}.join('&')
      end

      def amount
        (@order.total * 100).round.to_s
      end
  end
end
