Rails.application.reloader.to_prepare do
  Liquid::Environment.default.register_filter(ActionView::Helpers::NumberHelper)
  Liquid::Environment.default.register_filter(ApplicationHelper)
  Liquid::Environment.default.register_filter(ProductsHelper)
end
