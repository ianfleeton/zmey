# == Order
#
# Stores details of an order placed on the website.
#
# === Attributes
#
# +customer_note+::
#   A note that may be left by the customer. The +customer_note+ field may be
#   used in different ways based on the merchant's needs.
#
# +delivery_instructions+::
#   A note left by the customer or administrator specifically for delivery
#   instructions.
#
# +email_address+::
#   Email address as entered by the customer. Email addresses are required for
#   all orders.
#
# +ip_address+::
#   IP address of the customer's host at the time the order was placed.
#
# +order_number+::
#   Unique order reference. May contain alphanumeric characters and hyphens.
#
# +po_number+::
#   A purchase order (PO) number provided by the customer.
#
# +processed_at+::
#   When the order was processed. This can be used to help integrate with
#   external systems such as accounts or stock control software. This is not
#   used by Zmey internally.
#
# +shipping_amount+::
#   Shipping amount excluding tax.
#
# +shipped_at+::
#   When the order contents were shipped.
#
# +shipment_email_sent_at+::
#   When the shipment email was sent to the customer.
#
# +shipping_method+::
#   String describing the shipping method chosen for the order.
#
# +shipping_tracking_number+::
#   A tracking number or code used to track the progress of the shipment with
#   the courier.
#
# +status+::
#   Status of payment for the order. One of <tt>Enums::PaymentStatus::VALUES</tt>.
#
# === Associations
#
# +basket+::
#   The customer's basket at the time the order was placed. This is stored so
#   that the basket can be emptied after the order has been completed.
#
# +order_lines+::
#   Describe each line of the order. Each OrderLine can include purchase of a
#   product or may be a discount adjustment.
#
# +shipments+::
#   Shipments containing items in this order.
#
# +payments+::
#   Payments, successful or otherwise, that have been recorded for this order.
#   A complete order can have zero, one or many payments.
#
# +user+::
#   The User account associated with the order. This is set when orders are
#   placed by registered customers.
class Order < ActiveRecord::Base
  include Enums
  include Enums::Conversions

  validates_presence_of :email_address
  validates_presence_of :billing_address_line_1,  :billing_town_city,  :billing_postcode,  :billing_country_id
  validates_presence_of :delivery_address_line_1, :delivery_town_city, :delivery_postcode, :delivery_country_id, if: -> { requires_delivery_address? }
  validates_uniqueness_of :order_number

  before_save :calculate_total
  before_create :create_order_number

  # Associations
  belongs_to :billing_country,  class_name: 'Country'
  belongs_to :delivery_country, class_name: 'Country'
  belongs_to :basket
  belongs_to :user
  has_many :order_comments, dependent: :delete_all, inverse_of: :order
  has_many :order_lines, dependent: :delete_all, inverse_of: :order
  has_many :payments, dependent: :delete_all
  has_many :shipments, dependent: :delete_all, inverse_of: :order

  validates_inclusion_of :status, in: Enums::PaymentStatus::VALUES

  # Deletes all orders that have not received payment and are older than +age+.
  def self.purge_old_unpaid(age = 1.month)
    self.destroy_all(["created_at < ? and status = ?", Time.now - age, PaymentStatus::WAITING_FOR_PAYMENT])
  end

  # Returns a new order or recycles a previous order specified by +id+ if that
  # order is eligible for recycling, that is, it exists and is in the waiting
  # for payment state.
  def self.new_or_recycled(id)
    if (order = find_by(id: id)) && order.status == Enums::PaymentStatus::WAITING_FOR_PAYMENT
      order.order_lines.delete_all
      order
    else
      new
    end
  end

  # String representation of the order. Returns the order number.
  def to_s
    order_number
  end

  # Empties the basket associated with this order if there is one.
  def empty_basket
    basket.basket_items.destroy_all if basket
  end

  # Returns +true+ if payment has been received.
  def payment_received?
    status == Enums::PaymentStatus::PAYMENT_RECEIVED
  end

  # An order is locked when payment is received. When an order is locked its
  # contents should not be updated. Shipments and comments can still be
  # added.
  alias_method :locked?, :payment_received?

  # Returns the sum of all accepted payment amounts.
  def amount_paid
    accepted_payments.sum(:amount).to_f
  end

  def accepted_payments
    payments.where(accepted: true)
  end

  # Returns the amount still left to be paid.
  def outstanding_payment_amount
    total - amount_paid
  end

  # Transitions the status to PAYMENT_RECEIVED if sufficient payments have
  # been received.
  def payment_accepted(payment)
    if outstanding_payment_amount <= 0
      self.status = Enums::PaymentStatus::PAYMENT_RECEIVED
      save
    end
  end

  # Copies +address+ (an Address) into the +email_address+ and
  # <tt>delivery_*</tt> attributes.
  def copy_delivery_address(address)
    self.email_address = address.email_address
    copy_address(:delivery, address)
  end

  # Copies +address+ (an Address) into the <tt>billing_*</tt> attributes.
  def copy_billing_address(address)
    copy_address(:billing, address)
  end

  # Returns a new Address from the +email_address+ and <tt>delivery_*</tt>
  # attributes.
  def delivery_address
    Address.new(
      email_address:  email_address,
      full_name:      delivery_full_name,
      address_line_1: delivery_address_line_1,
      address_line_2: delivery_address_line_2,
      town_city:      delivery_town_city,
      county:         delivery_county,
      postcode:       delivery_postcode,
      country_id:     delivery_country_id,
      phone_number:   delivery_phone_number
    )
  end

  # Calculates the total, including shipping and taxes, and assigns it to
  # +total+. This is called +before_save+.
  def calculate_total
    t = total_gross
    t = t + 0.0001 # in case of x.x499999
    t = (t * 100).round.to_f / 100
    self.total = t
  end

  # Total amount for the order including shipping but excluding any taxes.
  def total_net
    shipping_amount + line_total_net
  end

  # Overall total amount for the order including shipping and all taxes.
  def total_gross
    shipping_amount_gross + line_total_gross
  end

  # Shipping amount including shipping tax.
  def shipping_amount_gross
    shipping_amount + shipping_tax_amount
  end

  # Total amount of all order lines excluding any tax.
  def line_total_net
    order_lines.inject(0) {|sum, l| sum + l.line_total_net}
  end

  # Total amount of all order lines including any tax.
  def line_total_gross
    order_lines.inject(0) {|sum, l| sum + l.line_total_net + l.tax_amount}
  end

  # Tax amount for all order lines.
  def line_tax_total
    order_lines.inject(0) { |sum, l| sum + l.tax_amount }
  end

  # Tax amount for the whole order including any shipping tax.
  def tax_total
    line_tax_total + shipping_tax_amount
  end

  # Weight of all products in this order.
  def weight
    order_lines.inject(0) { |sum, l| sum + l.weight }
  end

  # Create an order number and assign to +order_number+.
  #
  # Order numbers include date but are not sequential so as to prevent
  # competitor analysis of sales volume.
  #
  # Called +before_create+.
  def create_order_number
    return if order_number.present?

    alpha = %w(0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    # try a short order number first
    # in case of collision, increase length of order number
    (4..10).each do |length|
      self.order_number = Time.now.strftime("%Y%m%d-")
      length.times {self.order_number += alpha[rand 36]}
      existing_order = Order.find_by(order_number: order_number)
      return if existing_order.nil?
    end
  end

  # Records preferred delivery date.
  #
  # * <tt>settings</tt> is an instance of <tt>PreferredDeliveryDateSettings</tt>.
  # * <tt>date</tt> is a string representation of a date which is expected to
  #   match the format in the settings.
  def record_preferred_delivery_date(settings, date)
    return unless date && settings

    date = Date.strptime(date, settings.date_format)

    raise(ArgumentError, 'date is not valid in accordance with settings') unless settings.valid_date?(date)

    self.preferred_delivery_date = date
    self.preferred_delivery_date_prompt = settings.prompt
    self.preferred_delivery_date_format = settings.date_format
    self
  end

  # Adds the contents of <tt>basket</tt> to the order and associates the basket
  # with the order.
  #
  # Keeping the basket with the order allows the basket to be cleaned up later
  # during payment callbacks which do not have user session information.
  #
  # The customer note and delivery instructions are also copied from the
  # basket to the order.
  def add_basket(basket)
    add_basket_items(basket.basket_items)
    self.basket = basket
    self.customer_note = basket.customer_note
    self.delivery_instructions = basket.delivery_instructions
  end

  # Creates an <tt>OrderLine<tt> for each <tt>BasketItem</tt> in
  # <tt>items</tt>.
  def add_basket_items(items)
    items.each do |i|
      self.order_lines.build(
        product_id: i.product.id,
        product_sku: i.product.sku,
        product_name: i.product.name,
        product_rrp: i.product.rrp,
        product_price: i.product.price_ex_tax(i.quantity),
        product_weight: i.product.weight,
        tax_amount: i.product.tax_amount(i.quantity) * i.quantity,
        quantity: i.quantity,
        feature_descriptions: i.feature_descriptions
      )
    end
  end

  # Returns +true+ if all order contents have been shipped, otherwise +false+.
  def fully_shipped?
    shipments.where(partial: false).where('shipped_at IS NOT NULL').any?
  end

  def to_webhook_payload(event)
    {
      order: {
        id: id,
        href: Rails.application.routes.url_helpers.api_admin_order_url(self, host: Website.first.domain),
        email_address: email_address,
        status: PaymentStatus(status).to_api,
        total: total
      }
    }
  end

  # Implements a fast deletion of all orders and dependents.
  def self.fast_delete_all
    Payment.delete_all
    OrderLine.delete_all
    Order.delete_all
  end

  # Convenience setter.
  def billing_country_name=(name)
    self.billing_country = Country.find_by(name: name) || billing_country
  end

  # Convenience setter.
  def delivery_country_name=(name)
    self.delivery_country = Country.find_by(name: name) || delivery_country
  end

  # Returns <tt>true</tt> if a sales conversion should be recorded for this
  # order.
  def should_record_sales_conversion?
    payment_received? && !sales_conversion_recorded_at
  end

  # Sets <tt>sales_conversion_recorded_at</tt> to now and saves the order.
  def record_sales_conversion!
    self.sales_conversion_recorded_at = Time.zone.now
    save
  end

  private

  def copy_address(address_type, address)
    [
      :address_line_1, :address_line_2, :address_line_3, :company, :country_id,
      :county, :full_name, :phone_number, :postcode, :town_city
    ].each do |component|
      setter = "#{address_type}_#{component}="
      send(setter, address.send(component))
    end
  end
end
