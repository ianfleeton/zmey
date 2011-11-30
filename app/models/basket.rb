class Basket < ActiveRecord::Base
  # basket items are destroyed so that their feature selections can be cleaned up
  has_many :basket_items, :dependent => :destroy
  has_one :order, :dependent => :nullify

  def total(inc_tax)
    total = 0.0
    basket_items.each {|i| total += i.line_total(inc_tax)}
    total
  end

  def vat_total
    total = 0.0
    basket_items.each {|i| total += i.product.tax_amount(i.quantity) * i.quantity}
    total
  end

  def apply_shipping?
    apply = false
    basket_items.each {|i| apply = true if i.product.apply_shipping?}
    apply
  end

  def shipping_supplement
    supplement = 0.0
    basket_items.each {|i| supplement += i.product.shipping_supplement * i.quantity}
    supplement
  end

  def self.purge_old(age = 1.month)
    self.destroy_all(["created_at < ?", Time.now - age])
  end
end
