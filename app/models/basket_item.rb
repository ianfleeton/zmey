class BasketItem < ActiveRecord::Base
  validates_numericality_of :quantity, :greater_than_or_equal_to => 1
  belongs_to :product
  has_many :feature_selections, :order => :id, :dependent => :delete_all
  before_save :update_features

  def line_total
    quantity * product.price
  end

  def self.describe_feature_selections fs
    fs.map {|fs| fs.description}.join('|')
  end
  
  # generates a text description of the features the customer has selected and
  # described for this item in the basket
  def update_features
    self.feature_descriptions = BasketItem.describe_feature_selections(feature_selections)
  end
end
