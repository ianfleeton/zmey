class FeatureSelection < ActiveRecord::Base
  belongs_to :feature
  belongs_to :basket_item
  def description
    d = feature.name + ': '
    case feature.ui_type
    when Feature::TEXT_FIELD, Feature::TEXT_AREA
      d += customer_text
    when Feature::CHECK_BOX
      d += checked ? 'Yes' : 'No'
    when Feature::DROP_DOWN, Feature::RADIO_BUTTONS
      d += choice.name
    end
  end
end
