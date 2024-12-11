class SagePay
  def initialize(opts)
    [
      :encrypted,
      :pre_shared_key,
      :vendor_tx_code,
      :amount,
      :delivery_surname,
      :delivery_firstnames,
      :delivery_address,
      :delivery_city,
      :delivery_post_code,
      :delivery_country,
      :success_url,
      :failure_url
    ].each { |o| instance_variable_set(:"@#{o}", opts[o]) }
  end

  def encrypt
    Base64.encode64(tx_string.xor(@pre_shared_key))
  end

  def decrypt
    # Allows for values to contain '='
    split = plaintext.split("&").map { |x| x.split("=", 2) }.flatten
    Hash[*split]
  end

  def plaintext
    @plaintext ||= Base64.decode64(@encrypted.tr(" ", "+")).xor(@pre_shared_key)
  end

  def tx_string
    tx_vars.map { |k, v| "#{k}=#{CGI.escapeHTML(v.to_s)}" }.join("&")
  end

  def tx_vars
    @tx_vars ||= {
      "VendorTxCode" => @vendor_tx_code,
      "Amount" => @amount,
      "Currency" => "GBP",
      "Description" => "Web purchase",
      "SuccessURL" => @success_url,
      "FailureURL" => @failure_url,
      "BillingSurname" => "",
      "BillingFirstnames" => "",
      "BillingAddress" => "",
      "BillingCity" => "",
      "BillingPostCode" => "",
      "BillingCountry" => "",
      "DeliverySurname" => @delivery_surname,
      "DeliveryFirstnames" => @delivery_firstnames,
      "DeliveryAddress" => @delivery_address,
      "DeliveryCity" => @delivery_city,
      "DeliveryPostCode" => @delivery_post_code,
      "DeliveryCountry" => @delivery_country
    }
  end
end
