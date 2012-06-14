class Component < ActiveRecord::Base
  attr_accessible :name, :product_id

  has_many :features, dependent: :destroy
  has_many :permutations, dependent: :delete_all
  belongs_to :product

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :product_id
end
