module OrdersHelper
  def address_for_worldpay o
    h(o.address_line_1) + '&#10;' +
      h(o.address_line_2) + '&#10;' +
      h(o.county);
  end
end
