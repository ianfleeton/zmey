class ShippingCalculator
  def initialize(options)
    @options = options.reverse_merge add_tax: false, default_amount: 0.0
  end

  def amount
    amount = 0.0

    if @options[:basket].apply_shipping?
      amount = @options[:default_amount]
      amount_by_address = @options[:shipping_class].try(:amount_for_basket, @options[:basket])
      amount = amount_by_address.nil? ? amount : amount_by_address
    end

    amount + @options[:basket].shipping_supplement
  end

  def tax_amount
    if @options[:add_tax] && (@options[:shipping_class].nil? || @options[:shipping_class].charge_tax?)
      Product::VAT_RATE * amount.to_f
    else
      0
    end
  end
end
