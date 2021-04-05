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
# +invoiced_at+::
#   The time when the order became an invoice.
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
#   Shipping amount excluding VAT.
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
# +status+::
#   Status of payment for the order. One of <tt>Enums::PaymentStatus::VALUES</tt>.
#
# +token+::
#   A secure random token used to claim ownership of the order without being
#   signed in, such as when using the public API.
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
  require "order_number_generator"
  include Enums
  include Enums::Conversions
  include TotalMoney

  has_secure_token

  # Validations
  validates_presence_of :email_address
  validates_presence_of :billing_address_line_1, :billing_town_city, :billing_postcode, :billing_country_id
  validates_presence_of :delivery_address_line_1, :delivery_town_city, :delivery_postcode, :delivery_country_id, if: -> { requires_delivery_address? }
  validates_uniqueness_of :order_number
  validates_format_of :vat_number, with: /\A(
    (AT)?U[0-9]{8} |                              # Austria
    (BE)?0?[0-9]{9} |                             # Belgium
    (BG)?[0-9]{9,10} |                            # Bulgaria
    (CY)?[0-9]{8}L |                              # Cyprus
    (CZ)?[0-9]{8,10} |                            # Czech Republic
    (DE)?[0-9]{9} |                               # Germany
    (DK)?[0-9]{8} |                               # Denmark
    (EE)?[0-9]{9} |                               # Estonia
    (EL|GR)?[0-9]{9} |                            # Greece
    (ES)?[0-9A-Z][0-9]{7}[0-9A-Z] |               # Spain
    (FI)?[0-9]{8} |                               # Finland
    (FR)?[0-9A-Z]{2}[0-9]{9} |                    # France
    (GB)?([0-9]{9}([0-9]{3})?|[A-Z]{2}[0-9]{3}) | # United Kingdom
    (HU)?[0-9]{8} |                               # Hungary
    (IE)?[0-9]{7}[A-Z]{1,2} |                     # Ireland
    (IE)?[0-9][A-Z][0-9]{5}[A-Z] |                # Ireland 2
    (IT)?[0-9]{11} |                              # Italy
    (LT)?([0-9]{9}|[0-9]{12}) |                   # Lithuania
    (LU)?[0-9]{8} |                               # Luxembourg
    (LV)?[0-9]{11} |                              # Latvia
    (MT)?[0-9]{8} |                               # Malta
    (NL)?[0-9]{9}B[0-9]{2} |                      # Netherlands
    (PL)?[0-9]{10} |                              # Poland
    (PT)?[0-9]{9} |                               # Portugal
    (RO)?[0-9]{2,10} |                            # Romania
    (SE)?[0-9]{12} |                              # Sweden
    (SI)?[0-9]{8} |                               # Slovenia
    (SK)?[0-9]{10}                                # Slovakia
    )\Z/x, allow_blank: true

  # ActiveRecord callbacks
  before_save :calculate_total, :associate_with_user
  before_save :update_payment_status
  before_create :create_order_number
  before_validation :associate_with_user
  before_validation :tidy_vat_number

  # Associations
  belongs_to :billing_country, class_name: "Country"
  belongs_to :delivery_country, class_name: "Country", optional: true
  belongs_to :basket, optional: true
  belongs_to :user, optional: true
  has_many :collection_ready_emails, dependent: :delete_all
  has_many :discount_uses, dependent: :delete_all
  has_many :discounts, through: :discount_uses
  has_many :order_comments, dependent: :delete_all, inverse_of: :order
  has_many :order_lines, dependent: :delete_all, inverse_of: :order
  has_many :payments, dependent: :delete_all
  has_many :products, through: :order_lines
  has_many :product_groups, through: :products
  has_many :locations, -> { distinct }, through: :product_groups
  has_many :shipments, dependent: :delete_all, inverse_of: :order
  has_one :client, as: :clientable, dependent: :delete

  validates_inclusion_of :status, in: Enums::PaymentStatus::VALUES

  delegate :mobile_app?, to: :client, allow_nil: true
  delegate :ip_address, to: :client, allow_nil: true
  delegate :platform, to: :client, allow_nil: true

  # Returns the order whose order number matches the payment's cart_id.
  def self.matching_new_payment(payment)
    find_by(order_number: payment.cart_id)
  end

  def self.current(cookies)
    order_id = cookies.signed[:order_id]
    # Avoid unnecessary database query.
    find_by(id: order_id) if order_id
  end

  def self.current!(cookies)
    find(cookies.signed[:order_id])
  end

  # Deletes all orders that have not received payment and are older than +age+.
  def self.purge_old_unpaid(age = 1.month)
    where(["created_at < ? and status = ?", Time.now - age, PaymentStatus::WAITING_FOR_PAYMENT]).destroy_all
  end

  # String representation of the order. Returns the order number.
  def to_s
    order_number
  end

  # Returns truthy if the customer can update a basket associated with this
  # order.
  def can_update_basket?
    !(
      needs_shipping_quote? || quote? || payment_on_account? || pay_by_phone? ||
      payment_received?
    )
  end

  # Returns +true+ if payment has been received and the order is fully shipped.
  def invoice?
    (payment_on_account? || payment_received?) && fully_shipped?
  end

  # Returns the invoice date.
  def invoice_date
    invoiced_on || created_at.to_date
  end

  def invoiced_on
    invoiced_at.try(:to_date)
  end

  # Returns +true+ if the customer has chosen to pay by phone but has not yet
  # paid.
  def pay_by_phone?
    status == Enums::PaymentStatus::PAY_BY_PHONE
  end

  # Returns +true+ if credit has been given and payment not yet received.
  def payment_on_account?
    status == Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
  end

  # Returns +true+ if payment has been received.
  def payment_received?
    status == Enums::PaymentStatus::PAYMENT_RECEIVED
  end

  # Returns +true+ if the order is a pro forma invoice.
  def pro_forma?
    status == Enums::PaymentStatus::PRO_FORMA
  end

  # Returns +true+ if the order is a quote.
  def quote?
    status == Enums::PaymentStatus::QUOTE
  end

  def waiting_for_payment?
    status == Enums::PaymentStatus::WAITING_FOR_PAYMENT
  end

  def canceled?
    status == Enums::PaymentStatus::CANCELED
  end

  def needs_shipping_quote?
    status == Enums::PaymentStatus::NEEDS_SHIPPING_QUOTE
  end

  # Describes the appropriate order details paperwork type in English, such
  # as "invoice" for PAYMENT_RECEIVED or "quotation" for QUOTE.
  def paperwork_type
    if invoice?
      "sales invoice"
    elsif quote? || pay_by_phone?
      "quotation"
    elsif pro_forma?
      "pro forma invoice"
    else
      "order details"
    end
  end

  # Returns the sum of all accepted payment amounts.
  def amount_paid
    accepted_payments.sum(:amount).to_f
  end

  def accepted_payments
    payments.where(accepted: true)
  end

  # Returns the amount still left to be paid, taking credit notes into account.
  def outstanding_payment_amount
    (total - amount_paid).round(2)
  end

  # Whether or not the order is allowed to be shipped. An order is shippable if
  # its status is either Enums::PaymentStatus::PAYMENT_RECEIVED or
  # Enums::PaymentStatus::PAYMENT_ON_ACCOUNT and that the order is neither
  # on hold nor for collection.
  def shippable?
    can_supply? && !(on_hold? || collection?)
  end

  # Whether or not the order can be collected. An order can be collected if
  # the payment status is acceptable and the order is for collection but not
  # on hold or already shipped/collected.
  def collectable?
    can_supply? && collection? && !(on_hold? || fully_shipped?)
  end

  # Returns +true+ if the merchant can supply this order which is the case
  # if payment has been received or if the order is on a credit account.
  def can_supply?
    payment_received? || payment_on_account?
  end

  # Returns true if this order is to be collected rather than delivered.
  def collection?
    shipping_method == ShippingClass::COLLECTION
  end

  # Returns the delivery_date specified by customer, if set, or falls back
  # to the estimated_delivery_date. Can return nil if neither date has been
  # set.
  def relevant_delivery_date
    delivery_date || estimated_delivery_date
  end

  # Transitions the status to PAYMENT_RECEIVED and locks the order if sufficient
  # payments have been received.
  #
  # Transitions the status to WAITING_FOR_PAYMENT if the payment is negative
  # and there is still an outstanding payment amount.
  def payment_accepted(payment)
    payment_amount = payment.amount.to_f
    if outstanding_payment_amount <= 0
      fully_paid if payment_amount > 0
    elsif payment_amount < 0
      self.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
    end
    save
  end

  # Tells the order that it has been fully paid. Its status is then changed to
  # PAYMENT_RECEIVED and its paid_on date is set to today. The order is locked
  # and the invoice date is set. If the order has not yet been fully shipped
  # (note that a credit account order may be) then update the estimated delivery
  # date.
  def fully_paid
    self.status = Enums::PaymentStatus::PAYMENT_RECEIVED
    self.paid_on = Date.current
    self.locked = true
    update_estimated_delivery_date unless fully_shipped?
  end

  # Copies +address+ (an Address) into the <tt>delivery_*</tt> attributes.
  def copy_delivery_address(address)
    copy_address(:delivery, address)
  end

  # Copies +address+ (an Address) into the +email_address+ and
  # <tt>billing_*</tt> attributes.
  def copy_billing_address(address)
    self.email_address = address.email_address
    copy_address(:billing, address)
  end

  # Returns a new Address from the +email_address+ and <tt>billing_*</tt>
  # attributes.
  def billing_address
    Address.new(
      email_address: email_address,
      company: billing_company,
      full_name: billing_full_name,
      address_line_1: billing_address_line_1,
      address_line_2: billing_address_line_2,
      address_line_3: billing_address_line_3,
      town_city: billing_town_city,
      county: billing_county,
      postcode: billing_postcode,
      country_id: billing_country_id,
      phone_number: billing_phone_number
    )
  end

  # Returns a new Address from the +email_address+ and <tt>delivery_*</tt>
  # attributes.
  def delivery_address
    Address.new(
      email_address: email_address,
      full_name: delivery_full_name,
      address_line_1: delivery_address_line_1,
      address_line_2: delivery_address_line_2,
      town_city: delivery_town_city,
      county: delivery_county,
      postcode: delivery_postcode,
      country_id: delivery_country_id,
      phone_number: delivery_phone_number
    )
  end

  # Calculates the total, including shipping and taxes, and assigns it to
  # +total+. This is called +before_save+.
  def calculate_total
    self.total = total_money(total_gross)
  end

  # Demotes a status of PAYMENT_RECEIVED to WAITING_FOR_PAYMENT if there is an
  # outstanding payment amount for the current total.
  #
  # Promotes a status of WAITING_FOR_PAYMENT to PAYMENT_RECEIVED if there is no
  # outstanding payment amount for the current total, or if that outstanding
  # amount is negative which may occur if, for example, a negative order line
  # has been added to the order.
  def update_payment_status
    outstanding = outstanding_payment_amount

    if outstanding > 0
      if payment_received?
        self.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
      end
    elsif waiting_for_payment?
      self.status = Enums::PaymentStatus::PAYMENT_RECEIVED
    end
  end

  # Total amount for the order including shipping but excluding any VAT.
  def total_net
    shipping_amount + line_total_net
  end

  # Overall total amount for the order including shipping and all VAT.
  def total_gross
    shipping_amount_gross + line_total_gross
  end

  # Shipping amount including any applicable shipping VAT.
  # Tax is excluded if the order is zero-rated.
  def shipping_amount_gross
    shipping_amount + (zero_rated? ? 0 : shipping_vat_amount)
  end

  # Total amount of all order lines excluding any VAT.
  def line_total_net
    order_lines.inject(BigDecimal("0")) { |sum, l| sum + l.line_total_net }
  end

  # Total amount of all order lines including any applicable VAT.
  # VAT is excluded if the order is zero-rated.
  def line_total_gross
    zr = zero_rated?
    order_lines.inject(BigDecimal("0")) do |sum, l|
      sum + l.line_total_net + (zr ? 0 : l.vat_amount)
    end
  end
  alias_method :total_for_shipping, :line_total_gross

  # VAT amount for all order lines.
  def line_vat_total
    order_lines.inject(0) { |sum, l| sum + l.vat_amount }
  end

  # VAT amount for the whole order including any shipping VAT.
  def vat_total
    line_vat_total + shipping_vat_amount
  end

  # Weight of all products in this order.
  def weight
    order_lines.inject(0) { |sum, l| sum + l.weight }
  end

  # Create an order number and assign to +order_number+.
  #
  # Called +before_create+.
  def create_order_number
    return if order_number.present?

    generator = OrderNumberGenerator.get_generator(self)
    self.order_number = generator.generate
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
    add_lines(basket.to_order_lines)
    self.basket = basket
    self.customer_note = basket.customer_note
    self.delivery_instructions = basket.delivery_instructions
  end

  def add_discount_lines(discount_lines)
    add_lines(discount_lines.map(&:to_order_line))
  end

  # Creates an <tt>OrderLine<tt> for each <tt>BasketItem</tt> in
  # <tt>items</tt>.
  def add_basket_items(items)
    items.each do |i|
      order_lines.build(
        product_id: i.product.id,
        product_sku: i.product.sku,
        product_name: i.product.name,
        product_rrp: i.product.rrp,
        product_price: i.product.price_ex_vat(i.quantity),
        product_weight: i.product.weight,
        vat_amount: i.product.vat_amount(i.quantity) * i.quantity,
        quantity: i.quantity,
        feature_descriptions: i.feature_descriptions
      )
    end
  end

  def add_lines(lines)
    order_lines << lines
  end

  def lead_time
    order_lines.map(&:lead_time).max || 0
  end

  # Returns despatch date, or if it;s not set, yesterday.
  def relevant_dispatch_date
    dispatch_date || Date.yesterday
  end

  # Updates the estimated_delivery_date attribute with a new estimate.
  def update_estimated_delivery_date
    return if delivery_date

    # TODO: Don't hardcode cutoff.
    odd = Shipping::OrderDispatchDelivery.new(self, cutoff: 12)
    self.estimated_delivery_date = odd.delivery_dates.first
    self.dispatch_date = odd.dispatch_date
  end

  # Returns +true+ if all order contents have been shipped, otherwise +false+.
  def fully_shipped?
    shipments.where(partial: false).where("shipped_at IS NOT NULL").any?
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

  # Associates this order with a user having a matching email address if a user
  # is not already assigned.
  def associate_with_user
    if user_id.nil? || user.email == Address::PLACEHOLDER_EMAIL
      self.user_id = User.find_or_create_by_details(
        email: email_address, name: billing_full_name
      ).id
    end
  end

  def tidy_vat_number
    self.vat_number = vat_number.present? ? vat_number.upcase.gsub(/[^A-Z0-9]/, "") : nil
  end

  def zero_rated?
    ::Orders::TaxStatus.new(self).zero_rated?
  end

  def set_email_confirmation_token
    self.email_confirmation_token = Security::RandomToken.new
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
