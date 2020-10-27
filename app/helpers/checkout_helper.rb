module CheckoutHelper
  def checkout_steps
    [
      "Your details",
      "Billing address",
      "Shipping address",
      "Review your order",
      "Secure payment",
      "Order confirmation"
    ]
  end

  # Renders a form tag for the PayPal payments form. Set
  # <tt>sandbox</tt> to <tt>true</tt> to send the customer to the
  # PayPal sandbox (test site), or <tt>false</tt> to send them to
  # the live site.
  def paypal_form_tag(sandbox:, &block)
    url = if sandbox
      "https://www.sandbox.paypal.com/cgi-bin/webscr"
    else
      "https://www.paypal.com/cgi-bin/webscr"
    end
    "<form action=\"#{url}\" name=\"_xclick\" method=\"post\">".html_safe + capture(&block) + "</form>".html_safe
  end

  # Returns an array of hidden field name/value pairs for use in the Yorkshire
  # Payments payment form.
  def yorkshire_payments_hidden_fields(order:, merchant_id:, callback_url:, redirect_url:, pre_shared_key:)
    field_list = YorkshirePayments::FieldList.new(
      order: order,
      merchant_id: merchant_id,
      callback_url: callback_url,
      redirect_url: redirect_url,
      pre_shared_key: pre_shared_key
    )
    field_list.fields
  end

  def bacs_only?(order)
    order.total > 2000
  end
end
