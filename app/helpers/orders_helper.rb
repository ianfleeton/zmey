module OrdersHelper
  def address_for_worldpay o
    h(o.address_line_1) + "&#10;" +
      h(o.address_line_2) + "&#10;" +
      h(o.county)
  end

  def payment_status(order)
    Enums::Conversions::PaymentStatus(order.status).to_s
  end

  # Returns a label for the relevant date depending on the status of the order,
  # such as whether it has been invoiced or if it is a quote.
  def order_date_label(order)
    if order.invoiced_at
      "Invoice"
    elsif order.quote?
      "Quotation"
    else
      "Order"
    end + " Date"
  end

  # Returns the order date and time, formatted. The invoiced_at time is used if
  # set, otherwise the order created_at time is used.
  def order_formatted_time(order)
    time = order.invoiced_at || order.created_at
    time.strftime(ApplicationHelper::FRIENDLY_TIME_FORMAT)
  end

  def sage_pay_form_url(test_mode)
    "https://#{test_mode ? "test" : "live"}.sagepay.com/gateway/service/vspform-register.vsp"
  end

  def record_sales_conversion(order)
    Orders::SalesConversion.new(order).record!
    render(partial: "orders/google_sales_conversion", locals: {order: order})
  end

  # Returns the bank account number for the currently active website.
  def bank_account_number
    "ACCOUNTNUMBER"
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

  # Returns the billing address formatted for use on the sales invoice.
  def sales_invoice_billing_address(order)
    components = [
      order.billing_company,
      vat_number_description(order),
      order.billing_address_line_1,
      order.billing_address_line_2,
      order.billing_address_line_3,
      order.billing_town_city,
      order.billing_county,
      order.billing_postcode,
      order.billing_country
    ]
    order_document_address(components)
  end

  # Returns the delivery address formatted for use on the sales invoice.
  def sales_invoice_delivery_address(order)
    components = [
      order.delivery_company,
      order.delivery_address_line_1,
      order.delivery_address_line_2,
      order.delivery_address_line_3,
      order.delivery_town_city,
      order.delivery_county,
      order.delivery_postcode,
      order.delivery_country
    ]
    order_document_address(components)
  end

  def picking_list_delivery_address(order)
    return "Collection" if order.collection?

    components = [
      order.delivery_full_name,
      order.delivery_company,
      order.delivery_address_line_1,
      order.delivery_address_line_2,
      order.delivery_address_line_3,
      order.delivery_town_city,
      order.delivery_county,
      order.delivery_postcode,
      order.delivery_country
    ]
    order_document_address(components)
  end

  private

  def vat_number_description(order)
    if order.vat_number.present?
      "VAT No.: #{order.vat_number}"
    else
      ""
    end
  end

  def order_document_address(components)
    raw components
      .map { |c| c.blank? ? nil : c }
      .compact
      .map { |c| h(c) }
      .join("<br>".html_safe)
  end
end
