class Product < ActiveRecord::Base
  MAX_PRICE = 100_000
  include ExtraAttributes

  validates_presence_of :name, :sku
  validates_uniqueness_of :sku
  validates_presence_of :image, unless: proc { |p| p.image_id.nil? }
  validates :google_description, length: {maximum: 5000}
  validates :meta_description, length: {maximum: 255}
  validates :price, numericality: {greater_than_or_equal_to: 0}

  PRICE_CALCULATORS = {
    "basic" => PriceCalculator::Base,
    "quantity_based" => PriceCalculator::QuantityBased
  }
  validates_inclusion_of :pricing_method, in: PRICE_CALCULATORS.keys

  # Google feed attributes
  AGE_GROUPS = %w[adult kids]
  validates_inclusion_of :age_group, in: AGE_GROUPS, allow_blank: true
  AVAILABILITIES = ["in stock", "available for order", "out of stock", "preorder"]
  validates_inclusion_of :availability, in: AVAILABILITIES
  CONDITIONS = %w[new used refurbished]
  validates_inclusion_of :condition, in: CONDITIONS
  GENDERS = %w[female male unisex]
  validates_inclusion_of :gender, in: GENDERS, allow_blank: true

  has_many :product_placements, dependent: :delete_all
  has_many :additional_products, dependent: :delete_all
  has_many :pages, through: :product_placements
  has_many :components, dependent: :destroy
  has_many :features, dependent: :destroy
  has_many :quantity_prices, -> { order "quantity" }, dependent: :delete_all

  # Images
  belongs_to :image, optional: true
  has_many :product_images, dependent: :delete_all
  has_many :images, through: :product_images

  has_many :order_lines, dependent: :nullify
  has_many :orders, through: :order_lines
  has_many :product_group_placements, dependent: :delete_all
  has_many :product_groups, through: :product_group_placements
  has_many :locations, through: :product_groups
  has_many :related_product_scores, -> { order "score DESC" }, dependent: :delete_all
  has_many :related_products, through: :related_product_scores
  has_many :basket_items, dependent: :destroy

  liquid_methods :id, :description, :full_detail, :name, :path, :rrp?, :rrp, :shipping_supplement, :sku, :url

  before_save :set_nil_weight_to_zero
  after_save :include_main_image_in_images

  # Tax types
  NO_TAX = 1
  INC_VAT = 2
  EX_VAT = 3

  TAX_TYPES = [NO_TAX, INC_VAT, EX_VAT]
  validates_inclusion_of :tax_type, in: TAX_TYPES

  VAT_RATE = 0.2
  def self.vat_rate
    VAT_RATE
  end

  def name_with_sku
    name + " [" + sku + "]"
  end

  # Returns the name of the main image, or <tt>nil</tt> if unset.
  def image_name
    image.try(:name)
  end

  # Set image by using the image's name.
  def image_name=(name)
    self.image = Image.find_by(name: name)
  end

  # Returns the names of all images delimieted with the pipe character.
  def image_names
    images.map { |i| i.name }.join("|")
  end

  # Set images by using the image names.
  # Provide the names as either an array or as a string delimited with the
  # pipe character.
  #   product.image_names = ['front.jpg', 'back.jpg']
  #   product.image_names = 'front.jpg|back.jpg'
  def image_names=(names)
    self.images = []
    names = names.split("|") if names.is_a?(String)
    names.each do |name|
      self.images <<= Image.find_by(name: name)
    end
  end

  # Assigns this product to the sole product group <tt>group</tt>, which can be
  # an instance of <tt>ProductGroup</tt> or the name of a
  # <tt>ProductGroup</tt>.
  #
  # All other associated product groups are removed.
  def product_group=(group)
    product_group_placements.delete_all
    if group.is_a?(String)
      group = ProductGroup.find_by(name: group)
    end
    if group
      ProductGroupPlacement.create(product: self, product_group: group)
    end
  end

  # Returns a <tt>PriceCalculator</tt> to work out the price of this product
  # in a basket.
  def price_calculator(params)
    @price_calculator ||= price_calculator_class.new(params.merge(product: self))
  end

  # the price of a single product when quantity q is purchased as entered
  # by the merchant -- tax is not considered
  def price_at_quantity(q)
    p = price
    if (q > 1) && !quantity_prices.empty?
      quantity_prices.each { |qp| p = qp.price if q >= qp.quantity }
    end
    p
  end

  # the amount of tax for a single product when quantity q is purchased
  def tax_amount(q = 1)
    price_inc_tax(q) - price_ex_tax(q)
  end

  # the price exclusive of tax for a single product when quantity q is purchased
  def price_ex_tax(q = 1)
    Taxer.new(price_at_quantity(q), tax_type).ex_tax
  end

  # the price inclusive of tax for a single product when quantity q is purchased
  def price_inc_tax(q = 1)
    Taxer.new(price_at_quantity(q), tax_type).inc_tax
  end

  # the price for a single product when quantity q is purchased with tax included
  # if inc_tax is true or tax excluded if inc_tax is false
  def price_with_tax(q, inc_tax)
    if inc_tax
      price_inc_tax(q)
    else
      price_ex_tax(q)
    end
  end

  def rrp_inc_tax
    Taxer.new(rrp, tax_type).inc_tax
  end

  def rrp_ex_tax
    Taxer.new(rrp, tax_type).ex_tax
  end

  def rrp?
    rrp.present?
  end

  def reduced?
    rrp? && price < rrp
  end

  def full_price?
    !reduced?
  end

  def path
    "/products/" + to_param
  end

  def slug
    "products/" + to_param
  end

  def url
    Website.first.url + path
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def self.for_google
    where(submit_to_google: true)
  end

  def self.delete_all
    destroy_all
  end

  def delete
    destroy
  end

  # Returns products matched by search +query+.
  def self.admin_search(query)
    words = query.split(" ")
    q = Product
    words.each { |word| q = q.where(["name LIKE ? OR sku = ?", "%#{word}%", word]) }
    q.limit(100)
  end

  # Returns the title appropriate for Google Products Feed.
  def title_for_google
    google_title.present? ? google_title : name
  end

  # Returns the description appropriate for Google Products Feed.
  def description_for_google
    google_description.present? ? google_description : description
  end

  def to_s
    name
  end

  # Deletes existing related products and generates new related products based
  # on how frequently other products are purchased with this one, using a simple
  # item-to-item collaborative filtering method.
  def generate_related_products
    related_product_scores.delete_all

    purchase_counts = Hash.new(0)

    orders.uniq.each do |order|
      order
        .order_lines
        .where("product_id != #{id} AND product_id IS NOT NULL")
        .pluck(:product_id)
        .uniq
        .each { |product_id| purchase_counts[product_id] += 1 }
    end

    scores = purchase_counts.map { |product_id, purchased|
      [product_id, relatedness(orders.count, purchased)]
    }.to_h

    scores.each_pair do |related_id, score|
      RelatedProductScore.create(product_id: id, related_product_id: related_id, score: score)
    end
  end

  def self.import_id
    "sku"
  end

  def self.exportable_attributes
    importable_attributes
  end

  def self.importable_attributes
    attribute_names + ["image_name", "image_names"] + extra_attribute_names
  end

  private

  # Returns a relatedness score between 0 and 1.
  # <tt>orders_count</tt> is the number of orders in which the first product is
  # present.
  # <tt>purchased_with_count</tt> is the number of those orders in which the
  # second product is also present.
  def relatedness(orders_count, purchased_with_count)
    raise "purchased_with_count cannot be larger than orders_count" if purchased_with_count > orders_count
    raise "orders_count must be > 0" if orders_count < 1
    raise "purchased_with_count must be > 0" if purchased_with_count < 1

    purchased_with_count / (orders_count**0.5 * purchased_with_count**0.5)
  end

  def set_nil_weight_to_zero
    self.weight ||= 0
  end

  def include_main_image_in_images
    if image
      unless images.include?(image)
        ProductImage.create(product_id: id, image_id: image.id)
      end
    end
  end

  def price_calculator_class
    PRICE_CALCULATORS[pricing_method]
  end
end
