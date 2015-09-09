module BasketHelper
  # Returns the total savings from RRP reductions and discounts. Incudes tax
  # if <tt>inc_tax</tt> is true. Returns a positive number for savings made.
  def total_savings(inc_tax)
    @basket.savings(inc_tax) + (discount_lines_price_total + (inc_tax ? discount_lines_tax_total : 0)) * -1
  end

  # Returns the total discount amount from discount lines excluding tax.
  def discount_lines_price_total
    if defined?(@discount_lines)
      @discount_lines.inject(0) { |acc, dl| acc + dl.price_adjustment }
    else
      0
    end
  end

  # Returns the total tax amount from discount lines.
  def discount_lines_tax_total
    if defined?(@discount_lines)
      @discount_lines.inject(0) { |acc, dl| acc + dl.tax_adjustment }
    else
      0
    end
  end
end
