module Admin::ShippingClassesHelper
  def table_rate_method_options
    [
      [I18n.t("helpers.admin.shipping_classes.table_rate_method_options.basket_total"), "basket_total"],
      [I18n.t("helpers.admin.shipping_classes.table_rate_method_options.weight"), "weight"]
    ]
  end
end
