module OrdersHelper
  def address_for_worldpay o
    h(o.address_line_1) + "&#10;" +
      h(o.address_line_2) + "&#10;" +
      h(o.county)
  end

  def payment_status(order)
    Enums::Conversions::PaymentStatus(order.status).to_s
  end

  def sage_pay_form_url(test_mode)
    "https://#{test_mode ? "test" : "live"}.sagepay.com/gateway/service/vspform-register.vsp"
  end

  def record_sales_conversion(order)
    Orders::SalesConversion.new(order).record!
    render(partial: "orders/google_sales_conversion", locals: {order: order})
  end

  def delivery_amount_description(order)
    if order.needs_shipping_quote?
      "[Awaiting quotation]"
    elsif order.shipping_amount == 0
      "Free"
    else
      formatted_price(order.shipping_amount)
    end
  end
end
