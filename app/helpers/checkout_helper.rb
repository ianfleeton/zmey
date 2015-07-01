module CheckoutHelper
  # Renders a form tag for the PayPal payments form. Set
  # <tt>sandbox</tt> to <tt>true</tt> to send the customer to the
  # PayPal sandbox (test site), or <tt>false</tt> to send them to
  # the live site.
  def paypal_form_tag(sandbox:, &block)
    url = if sandbox
            'https://www.sandbox.paypal.com/cgi-bin/webscr'
          else
            'https://www.paypal.com/cgi-bin/webscr'
          end
    "<form action=\"#{url}\" name=\"_xclick\" method=\"post\">".html_safe + capture(&block) + '</form>'.html_safe
  end

  # Returns an array of hidden field name/value pairs for use in the UPG
  # Atlas payment form.
  def upg_atlas_hidden_fields(order:, checkcode:, shreference:, callbackurl:, filename:, secuphrase:)
    field_list = UpgAtlas::FieldList.new(
      order: order,
      checkcode: checkcode,
      shreference: shreference,
      callbackurl: callbackurl,
      filename: filename,
      secuphrase: secuphrase,
    )
    field_list.fields
  end
end
