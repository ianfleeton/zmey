# Works out the prices with and without tax depending on the tax status
# of the price.
class Taxer
  def initialize(price, tax_type)
    @price, @tax_type = price, tax_type
  end

  def inc_vat
    if @price
      @tax_type == Product::EX_VAT ? @price * (1 + Product.vat_rate) : @price
    end
  end

  def ex_vat
    if @price
      @tax_type == Product::INC_VAT ? @price / (1 + Product.vat_rate) : @price
    end
  end
end
