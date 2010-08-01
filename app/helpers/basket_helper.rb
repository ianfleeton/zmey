module BasketHelper
  def discount_lines_price_total
    total = 0
    @discount_lines.each do |dl|
      total += dl.price_adjustment
    end
    total
  end

  def discount_lines_tax_total
    total = 0
    @discount_lines.each do |dl|
      total += dl.tax_adjustment
    end
    total
  end
end
