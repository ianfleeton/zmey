class Basket < ActiveRecord::Base
  # basket items are destroyed so that their feature selections can be cleaned up
  has_many :basket_items, inverse_of: :basket, dependent: :destroy
  has_one :order, dependent: :nullify

  before_create :generate_token

  def self.old
    where('updated_at < ?', 90.days.ago)
  end

  # Adds +product+ to the basket.
  # Yields the container +BasketItem+ for editing if a block is given.
  def add(product, feature_selections, quantity)
    feature_descriptions = BasketItem.describe_feature_selections(feature_selections)

    # Look for an item that is in our basket, has the same product ID
    # and also has the same feature selections by the user.
    # For example, a T-shirt product with a single SKU may come in green or red,
    # each of which should appear as a separate entry in our basket.
    item = BasketItem.find_by(basket_id: id, product_id: product.id, feature_descriptions: feature_descriptions)
    if item
      item.quantity += quantity
    else
      item = BasketItem.new(
        basket_id: id,
        product_id: product.id,
        quantity: quantity,
        feature_selections: feature_selections)
    end
    yield item if block_given?
    item.save
  end

  # Sets the quantity for each item in the basket matching the product ID.
  # Products that are not yet in the basket are added.
  # Products with a quantity of less than one are removed.
  # FeatureSelections are not supported.
  #
  # +quantities+ is a +Hash+ with product IDs for keys and quantities for
  # values.
  def set_product_quantities(quantities)
    quantities.each_pair do |product_id, quantity|
      quantity = quantity.to_i
      if quantity < 1
        BasketItem.where(basket_id: id, product_id: product_id).destroy_all
      else
        item = BasketItem.find_by(basket_id: id, product_id: product_id)
        if item
          item.quantity = quantity
          item.save
        else
          BasketItem.create(basket_id: id, product_id: product_id, quantity: quantity)
        end
      end
    end
  end

  def quantity_of_product(product)
    BasketItem.find_by(basket_id: id, product_id: product.id).try(:quantity) || 0
  end

  def items_at_full_price
    basket_items.select { |i| i.product.full_price? }
  end

  # Returns the sum of basket item savings.
  def savings(inc_tax)
    basket_items.inject(0) { |s, i| s + i.savings(inc_tax) }
  end

  # Returns true if any of the basket items have made savings.
  def savings?
    savings(false) > 0
  end

  # Returns true if any of the basket items are oversize.
  def oversize?
    basket_items.any? {|i| i.oversize?}
  end

  def weight
    basket_items.inject(0) { |w, i| w + i.weight }
  end

  def total(inc_tax)
    total = 0.0
    basket_items.each {|i| total += i.line_total(inc_tax)}
    total
  end

  # Returns +true+ if the basket is empty.
  def empty?
    basket_items.none?
  end

  # Returns +true+ if the basket contains <tt>product</tt>.
  def contains?(product)
    product_id = to_product_id(product)
    basket_items.exists?(product_id: product_id)
  end

  # Returns any basket items that contain <tt>product</tt>.
  def items_containing(product)
    product_id = to_product_id(product)
    basket_items.where(product_id: product_id)
  end

  # Returns the first basket item containing <tt>product</tt>.
  def item_containing(product)
    items_containing(product).first
  end

  # Returns the total quantity of items in the basket. Items that can have
  # fractional quantities are counted as 1 per line.
  def total_quantity
    basket_items.inject(0) {|q, i| q + i.counting_quantity}
  end

  def vat_total
    basket_items.inject(0) {|t, i| t + i.tax_amount}
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

  def generate_token
    self.token = SecureRandom.urlsafe_base64(nil, false)
  end

  # Returns a copy of this basket and its contents, but with a new token.
  def deep_clone
    b = dup
    b.generate_token
    b.save
    basket_items.each {|i| b.basket_items << i.dup}
    b
  end

  private

    def to_product_id(product)
      product.instance_of?(Product) ? product.id : product
    end
end
