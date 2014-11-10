# == Order
#
# Stores details of an order placed on the website.
#
# === Attributes
#
# +customer_note+::
#   A note that may be left by the customer, for example, additional delivery
#   instructions. The +customer_note+ field may be used in different ways based
#   on the merchant's needs.
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
# +processed_at+::
#   When the order was processed. This can be used to help integrate with
#   external systems such as accounts or stock control software. This is not
#   used by Zmey internally.
#
# +shipping_amount+::
#   Shipping amount excluding tax.
#
# +shipping_method+::
#   String describing the shipping method chosen for the order.
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
# +payments+::
#   Payments, successful or otherwise, that have been recorded for this order.
#   A complete order can have zero, one or many payments.
#
# +user+::
#   The User account associated with the order. This is set when orders are
#   placed by registered customers.
#
# +website+::
#   Website the customer was using to place the order.
class Order < ActiveRecord::Base
  include Enums
  include Enums::Conversions

  validates_presence_of :email_address
  validates_presence_of :billing_address_line_1,  :billing_town_city,  :billing_postcode,  :billing_country_id
  validates_presence_of :delivery_address_line_1, :delivery_town_city, :delivery_postcode, :delivery_country_id

  before_save :calculate_total
  before_create :create_order_number

  # Associations
  belongs_to :billing_country,  class_name: 'Country'
  belongs_to :delivery_country, class_name: 'Country'
  belongs_to :basket
  belongs_to :user
  belongs_to :website
  has_many :order_lines, dependent: :delete_all
  has_many :payments, dependent: :delete_all

  validates_inclusion_of :status, in: PaymentStatus::VALUES

  # Returns the order from the customer's session, or +nil+ if it does not
  # exist.
  def self.from_session session
    session[:order_id] ? find_by(id: session[:order_id]) : nil
  end

  # Deletes all orders that have not received payment and are older than +age+.
  def self.purge_old_unpaid(age = 1.month)
    self.destroy_all(["created_at < ? and status = ?", Time.now - age, PaymentStatus::WAITING_FOR_PAYMENT])
  end

  # String representation of the order. Returns the order number.
  def to_s
    order_number
  end

  # Empties the basket associated with this order if there is one.
  def empty_basket
    basket.basket_items.clear if basket
  end

  # Returns +true+ if payment has been received.
  def payment_received?
    status == Enums::PaymentStatus::PAYMENT_RECEIVED
  end

  # Copies +address+ (an Address) into the +email_address+ and
  # <tt>delivery_*</tt> attributes.
  def copy_delivery_address(address)
    self.email_address            = address.email_address
    self.delivery_full_name       = address.full_name
    self.delivery_address_line_1  = address.address_line_1
    self.delivery_address_line_2  = address.address_line_2
    self.delivery_town_city       = address.town_city
    self.delivery_county          = address.county
    self.delivery_postcode        = address.postcode
    self.delivery_country_id      = address.country_id
    self.delivery_phone_number    = address.phone_number
  end

  # Copies +address+ (an Address) into the <tt>billing_*</tt> attributes.
  def copy_billing_address(address)
    self.billing_full_name       = address.full_name
    self.billing_address_line_1  = address.address_line_1
    self.billing_address_line_2  = address.address_line_2
    self.billing_town_city       = address.town_city
    self.billing_county          = address.county
    self.billing_postcode        = address.postcode
    self.billing_country_id      = address.country_id
    self.billing_phone_number    = address.phone_number
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
    t = t + 0.001 # in case of x.x499999
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

  def to_webhook_payload(event)
    {
      order: {
        id: id,
        href: Rails.application.routes.url_helpers.api_admin_order_url(self, host: website.domain),
        email_address: email_address,
        status: PaymentStatus(status).to_api,
        total: total
      }
    }
  end
end
