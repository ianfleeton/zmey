class Feature < ActiveRecord::Base
  # validations
  validates_presence_of :name
  validates_uniqueness_of :name, scope: :product_id

  # associations
  has_many :choices, dependent: :destroy
  belongs_to :product
  belongs_to :component

  # UI types
  TEXT_FIELD = 1
  TEXT_AREA = 2
  RADIO_BUTTONS = 3
  DROP_DOWN = 4
  CHECK_BOX = 5

  def class_name
    {
      TEXT_FIELD => 'feature_text_field',
      TEXT_AREA => 'feature_text_area',
      RADIO_BUTTONS => 'feature_radio_buttons',
      DROP_DOWN => 'feature_drop_down',
      CHECK_BOX => 'feature_check_box'
    }[ui_type]
  end
end
