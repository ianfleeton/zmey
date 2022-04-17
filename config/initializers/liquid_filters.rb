Rails.application.reloader.to_prepare do
  Liquid::Template.register_filter(ActionView::Helpers::NumberHelper)
  Liquid::Template.register_filter(ApplicationHelper)
  Liquid::Template.register_filter(ProductsHelper)
end
