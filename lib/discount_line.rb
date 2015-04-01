class DiscountLine
  attr_accessor :mutually_exclusive_with, :name, :price_adjustment, :tax_adjustment

  def initialize(attrs = {})
    self.mutually_exclusive_with = attrs[:mutually_exclusive_with] || Set.new
    self.name = attrs[:name]
    self.price_adjustment = attrs[:price_adjustment]
    self.tax_adjustment = attrs[:tax_adjustment]
  end

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
