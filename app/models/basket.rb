class Basket < ActiveRecord::Base
  # basket items are destroyed so that their feature selections can be cleaned up
  has_many :basket_items, :dependent => :destroy
  has_one :order, :dependent => :nullify
  def total
    total = 0.0
    basket_items.each {|i| total += i.line_total}
    total
  end
  
  def apply_shipping?
    apply = false
    basket_items.each {|i| apply = true if i.product.apply_shipping?}
    apply
  end
  
  def self.purge_old(age = 1.month)
    self.destroy_all(["created_at < ?", Time.now - age])
  end
end
