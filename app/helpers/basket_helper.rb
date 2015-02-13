module BasketHelper
  # Returns the total discount amount from discount lines excluding tax.
  def discount_lines_price_total
    @discount_lines.inject(0) { |acc, dl| acc + dl.price_adjustment }
  end

  def discount_lines_tax_total
    total = 0
    @discount_lines.each do |dl|
      total += dl.tax_adjustment
    end
    total
  end
end
