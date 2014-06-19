class Country < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :iso_3166_1_alpha_2, is: 2
  validates_uniqueness_of :iso_3166_1_alpha_2, scope: :website_id

  belongs_to :website
  belongs_to :shipping_zone
  has_many :addresses, dependent: :restrict_with_exception
  has_many :delivery_orders, foreign_key: 'delivery_country_id', class_name: 'Order', dependent: :restrict_with_exception

  def to_s
    name
  end
end
