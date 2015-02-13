module BasketHelper
  # Returns the total discount amount from discount lines excluding tax.
  def discount_lines_price_total
    @discount_lines.inject(0) { |acc, dl| acc + dl.price_adjustment }
  end

  # Returns the total tax amount from discount lines.
  def discount_lines_tax_total
    @discount_lines.inject(0) { |acc, dl| acc + dl.tax_adjustment }
  end
end
