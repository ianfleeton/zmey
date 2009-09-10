class Basket < ActiveRecord::Base
  # basket items are destroyed so that their feature selections can be cleaned up
  has_many :basket_items, :dependent => :destroy
  def total
    total = 0.0
    basket_items.each {|i| total += i.line_total}
    total
  end
end
