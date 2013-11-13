class Component < ActiveRecord::Base
  has_many :features, dependent: :destroy
  has_many :permutations, dependent: :delete_all
  belongs_to :product

  validates_presence_of :name
  validates_uniqueness_of :name, scope: :product_id

  def to_s
    name
  end
end
