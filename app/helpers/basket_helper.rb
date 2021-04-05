module BasketHelper
  def basket_item_link(item)
    link_to(
      item.name,
      "#{item.path}?basket_item_id=#{item.id}"
    )
  end

  # Returns the total savings from RRP reductions and discounts. Incudes VAT
  # if <tt>inc_vat</tt> is true. Returns a positive number for savings made.
  def total_savings(basket, inc_vat)
    basket.savings(inc_vat) +
      -1 *
        (discount_lines_price_total + (inc_vat ? discount_lines_vat_total : 0))
  end

  # Returns the total discount amount from discount lines excluding VAT.
  def discount_lines_price_total
    if defined?(@discount_lines)
      @discount_lines.inject(0) { |acc, elem| acc + elem.price_adjustment }
    else
      0
    end
  end

  # Returns the total VAT amount from discount lines.
  def discount_lines_vat_total
    if defined?(@discount_lines)
      @discount_lines.inject(0) { |acc, elem| acc + elem.vat_adjustment }
    else
      0
    end
  end
end
