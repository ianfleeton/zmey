class Order < ActiveRecord::Base
  validates_presence_of :email_address, :address_line_1, :town_city, :postcode, :country_id

  before_save :calculate_total
  before_create :create_order_number

  # Associations
  belongs_to :country
  belongs_to :basket
  belongs_to :user
  belongs_to :website
  has_many :order_lines, dependent: :delete_all
  has_many :payments, dependent: :delete_all
  # Order statuses
  WAITING_FOR_PAYMENT = 1
  PAYMENT_RECEIVED    = 2
  PAYMENT_ON_ACCOUNT  = 3

  def self.from_session session
    session[:order_id] ? find_by(id: session[:order_id]) : nil
  end

  def self.purge_old_unpaid(age = 1.month)
    self.destroy_all(["created_at < ? and status = ?", Time.now - age, Order::WAITING_FOR_PAYMENT])
  end

  def to_s
    order_number
  end

  def status_description
    {
      WAITING_FOR_PAYMENT => 'Waiting for payment',
      PAYMENT_RECEIVED => 'Payment received',
      PAYMENT_ON_ACCOUNT => 'Payment on account'
    }[status]
  end

  def empty_basket(session)
    # TODO: I know too much; this code is used by PaymentsController and BasketController
    unless basket.nil?
      basket.basket_items.clear
    end
    unless session[:coupons].nil?
      session[:coupons] = nil
    end
  end

  def payment_received?
    status == Order::PAYMENT_RECEIVED
  end

  def copy_address a
    self.email_address   = a.email_address
    self.full_name       = a.full_name
    self.address_line_1  = a.address_line_1
    self.address_line_2  = a.address_line_2
    self.town_city       = a.town_city
    self.county          = a.county
    self.postcode        = a.postcode
    self.country_id      = a.country_id
    self.phone_number    = a.phone_number
  end

  def delivery_address
    Address.new(
      email_address: email_address,
      full_name: full_name,
      address_line_1: address_line_1,
      address_line_2: address_line_2,
      town_city: town_city,
      county: county,
      postcode: postcode,
      country_id: country_id,
      phone_number: phone_number
    )
  end

  def calculate_total
    t = total_gross
    t = t + 0.001 # in case of x.x499999
    t = (t * 100).round.to_f / 100
    self.total = t
  end

  # Total amount for the order excluding any taxes.
  def total_net
    shipping_amount + line_total_net
  end

  # Overall total amount for the order including all taxes.
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

  # create an order number
  # order numbers include date but are not sequential so as to prevent competitor analysis of sales volume
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

  # http://alt.pluralsight.com/wiki/default.aspx/Craig/BirthdayProblemCalculator.html
  # this method is not used
  # k = number of orders in a day
  # n = number of possible values for order number
  def probability_of_collision k, n
    1 - Math.exp((-k**2.0)/(2.0*n))
  end
end
