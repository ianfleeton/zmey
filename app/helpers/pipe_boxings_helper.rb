module PipeBoxingsHelper
  def boxings_form_for(product)
    render partial: 'pages/boxings_form', locals: { product: product }
  end

  def boxings_dimension_select(var)
    label = var.capitalize
    if var == 'width'
      var = 'height'
    end

    html = "<div><label for=\"#{var}\">#{label} (external)</label>".html_safe
    html += "<select id=\"#{var}\" name=\"#{var}\" onchange=\"updatePrice();\">".html_safe
    size = 50
    while(size <= 220) do
      html += "<option value=\"#{size}\">#{size}mm</option>\n".html_safe
      size += 10
    end
    html += "</select></div>\n".html_safe
  end

  def boxings_dimension_selects(use_width_instead_of_height)
    if use_width_instead_of_height
      html = boxings_dimension_select('width')
    else
      html = boxings_dimension_select('height')
    end
    html + boxings_dimension_select('depth')
  end

  def price_func_l_shape_1220
    '<script>updatePrice();</script>'
  end

  def price_func_l_shape_2440
    '<script>updatePrice();</script>'
  end

  def price_func_u_shape_1220
    '<script>updatePrice();</script>'
  end

  def price_func_u_shape_2440
    '<script>updatePrice();</script>'
  end

  def price_with_and_without_vat(ex_vat)
    number_to_currency(ex_vat, unit: '').html_safe +
      ' <span class="ex-vat">(inc VAT: &pound;'.html_safe +
      number_to_currency(ex_vat*1.2, unit: '').html_safe +
      ')</span>'.html_safe
  end

  def price_func_stop_end
    price_with_and_without_vat(2.50)
  end

  def price_func_external_corner
    price_with_and_without_vat(11.50)
  end

  def price_func_internal_corner
    price_with_and_without_vat(12.50)
  end

  def price_func_l_shape_joint_cover
    price_with_and_without_vat(3.60)
  end

  def price_func_u_shape_joint_cover
    price_with_and_without_vat(4.00)
  end
end
