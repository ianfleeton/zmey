module Admin::ProductsHelper
  def tax_type_options
    [
      [I18n.t('helpers.admin.products.tax_type_options.no_tax'), Product::NO_TAX],
      [I18n.t('helpers.admin.products.tax_type_options.inc_vat'), Product::INC_VAT],
      [I18n.t('helpers.admin.products.tax_type_options.ex_vat'), Product::EX_VAT]
    ]
  end
end
