module CheckoutHelper
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
