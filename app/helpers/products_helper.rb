module ProductsHelper
  def formatted_price price
    number_to_currency(price, unit: '£')
  end

  def formatted_gbp_price price
    number_to_currency(price, unit: 'GBP', format: '%n %u')
  end

  def tax_explanation(product)
    if @w.vat_number.empty?
      ''
    else
      if product.tax_type == Product::EX_VAT || product.tax_type == Product::INC_VAT
        if @inc_tax
          ' <span class="tax_explanation">inc VAT</span>'.html_safe
        else
          ' <span class="tax_explanation">ex VAT</span>'.html_safe
        end
      end
    end
  end

  # Returns a cache key for the collection of all products in +website+.
  def products_cache_key(website)
    [
      website.products.count,
      Product.where(website_id: website.id).order('updated_at DESC').first
    ]
  end
end
