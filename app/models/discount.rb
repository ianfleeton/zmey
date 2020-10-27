class Discount < ActiveRecord::Base
  # Associations
  has_many :discount_uses, dependent: :delete_all
  belongs_to :product_group, optional: true
  has_many :products, through: :product_group

  validates_numericality_of :reward_amount, greater_than_or_equal_to: 0, less_than: 10_000_000
  REWARD_TYPES = ["amount_off_order", "free_products", "percentage_off", "percentage_off_order"]
  validates_inclusion_of :reward_type, in: REWARD_TYPES
  validates_numericality_of :threshold, greater_than_or_equal_to: 0, less_than: 10_000_000

  validates :name, presence: true

  before_save :uppercase_coupon_code

  def to_s
    name
  end

  def self.currently_valid(code: nil)
    # This works even without specifically upcasing the passed in code arg.
    # This is because the collation for mysql should be set to case insensitive.
    # We upcase just in case a production database is not configured the same.
    code_to_find = code&.upcase
    where("code IS NULL OR code = ?", code_to_find).select(&:currently_valid?)
  end

  def self.current_percentage_off_order_discounts
    Discount.currently_valid.select { |discount| discount.reward_type == "percentage_off_order" }
  end

  def uppercase_coupon_code
    coupon.upcase!
  end

  def currently_valid?
    has_uses_remaining? && within_valid_dates?
  end

  def record_use
    if uses_remaining
      self.uses_remaining -= 1
      save
    end
  end

  private

  def has_uses_remaining?
    uses_remaining.nil? || uses_remaining.positive?
  end

  def within_valid_dates?
    if valid_from.nil? || valid_to.nil?
      true
    else
      Time.current >= valid_from && Time.current <= valid_to
    end
  end
end

