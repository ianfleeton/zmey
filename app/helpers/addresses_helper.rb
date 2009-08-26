module AddressesHelper
  # formats an address in HTML
  def format_address a
    content_tag(
      :p,
      h(a.full_name) +
      ' &lt;' + h(a.email_address) + '&gt;<br />' + 
      h(a.address_line_1) + '<br />' +
      (a.address_line_2.empty? ? '' : h(a.address_line_2) + '<br />') +
      h(a.town_city) + ', ' +
      (a.county.empty? ? '' : h(a.county) + ', ') +
      h(a.postcode) +
      (a.phone_number.empty? ? '' : '<br />' + h(a.phone_number))
    )
  end
end
