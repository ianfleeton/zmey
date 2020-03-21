module AddressesHelper
  # formats an address in HTML
  def format_address a, html = true
    if html
      lt = "&lt;".html_safe
      gt = "&gt;".html_safe
      lb = "<br>".html_safe
    else
      lt = "<".html_safe
      gt = ">".html_safe
      lb = "\n"
    end
    address = h(a.full_name) +
      " " + lt + h(a.email_address) + gt + lb +
      h(a.address_line_1) + lb +
      (a.address_line_2.blank? ? "" : h(a.address_line_2) + lb) +
      h(a.town_city) + ", " +
      (a.county.blank? ? "" : h(a.county) + ", ") +
      h(a.postcode) +
      (a.phone_number.blank? ? "" : lb + h(a.phone_number))
    html ? content_tag(:p, address) : address
  end
end
