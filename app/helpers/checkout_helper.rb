module CheckoutHelper
  # Returns an array of hidden field name/value pairs for use in the UPG
  # Atlas payment form.
  def upg_atlas_hidden_fields(order:, checkcode:, shreference:, callbackurl:, filename:)
    field_list = UpgAtlas::FieldList.new(
      order: order,
      checkcode: checkcode,
      shreference: shreference,
      callbackurl: callbackurl,
      filename: filename,
    )
    field_list.fields
  end
end
