class DiscountLine
  attr_accessor :name, :price_adjustment, :tax_adjustment

  def price_with_tax(inc_tax)
    if inc_tax
      price_adjustment + tax_adjustment
    else
      price_adjustment
    end
  end

  def to_s
    "#{name}: #{price_adjustment} #{tax_adjustment}"
  end
end
