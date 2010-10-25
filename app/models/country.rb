class Country < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :iso_3166_1_alpha_2, :is => 2

  belongs_to :website
  belongs_to :shipping_zone
  has_many :addresses, :dependent => :nullify # Rails3 :restrict
  has_many :orders, :dependent => :nullify # Rails3 :restrict

  attr_protected :website_id
end
