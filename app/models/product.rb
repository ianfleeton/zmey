class Product < ActiveRecord::Base
  validates_presence_of :name, :sku
  validates_uniqueness_of :sku, :scope => :website_id

  has_many :pages, :through => :product_placement
  has_many :features, :dependent => :destroy
  has_many :quantity_prices, :order => :quantity, :dependent => :delete_all
  belongs_to :image

  # Tax types
  NO_TAX = 1
  INC_VAT = 2
  EX_VAT = 3
  
  def price_at_quantity(q)
    p = price
    if q > 1 and !quantity_prices.empty?
      quantity_prices.each {|qp| p = qp.price if q >= qp.quantity}
    end
    p
  end
  
  def tax_amount
    if tax_type == Product::EX_VAT
      price * 0.15
    else
      0
    end
  end
  
  def price_ex_tax
    if tax_type == Product::INC_VAT
      price / 1.15
    else
      price
    end
  end
  
  def price_inc_tax
    if tax_type == Product::EX_VAT
      price + tax_amount
    else
      price
    end
  end
end
