module FeaturesHelper
  def feature_ui_option(feature, ui_option, label)
    content_tag(:option, label, value: ui_option, selected: ui_option == feature.ui_type)
  end
end
