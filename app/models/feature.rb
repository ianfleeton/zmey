class Feature < ActiveRecord::Base
  # validations
  validates_presence_of :name
  # associations
  has_many :choices, :dependent => :delete_all
  belongs_to :product
  
  # UI types
  TEXT_FIELD = 1
  TEXT_AREA = 2
  RADIO_BUTTONS = 3
  DROP_DOWN = 4
  CHECK_BOX = 5
  
end
