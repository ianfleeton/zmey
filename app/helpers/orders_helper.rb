module OrdersHelper
  def address_for_worldpay o
    h(o.address_line_1) + '&#10;' +
      h(o.address_line_2) + '&#10;' +
      h(o.county);
  end

  def payment_status(order)
    Enums::Conversions::PaymentStatus(order.status).to_s
  end

  def sage_pay_form_url(test_mode)
    "https://#{test_mode ? 'test' : 'live'}.sagepay.com/gateway/service/vspform-register.vsp"
  end
end
