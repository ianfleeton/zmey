class Location < ApplicationRecord
  # Associations
  has_many :location_orders_exceeded_entries, dependent: :delete_all
  has_many :product_groups, -> { order :name }, dependent: :nullify

  # Validations
  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false

  def to_s
    name
  end

  def orders_dispatching_on(date)
    ds = Orders::DueStatus.new(today: date)
    ds.due_orders.count { |order|
      ds.departments(order).include?(name)
    }
  end

  def order_limit_reached?(date)
    if max_daily_orders > 0
      orders_dispatching_on(date) >= max_daily_orders
    end
  end
end
