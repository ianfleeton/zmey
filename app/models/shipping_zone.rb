class ShippingZone < ActiveRecord::Base
  belongs_to :website
  has_many :countries, :order => 'name', :dependent => :nullify

  validates_uniqueness_of :name, :scope => :website_id

  attr_protected :website_id
end
