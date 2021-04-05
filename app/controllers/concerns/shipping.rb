# frozen_string_literal: true

module Shipping
  extend ActiveSupport::Concern

  # Returns the current shipping class, memoized.
  def shipping_class
    @shipping_class ||= find_shipping_class(session[:shipping_class_id])
  end

  # Returns the current shipping class without memoization.
  def shipping_class!
    @shipping_class = find_shipping_class(session[:shipping_class_id])
  end

  def find_shipping_class(chosen_class_id)
    ShippingClassFinder.new(
      shipping_class_id: chosen_class_id,
      default_shipping_class: website.default_shipping_class,
      delivery_address: delivery_address,
      basket: basket
    ).find
  end

  protected

  # Returns the customer's delivery address or <tt>nil</tt> if the customer
  # has not yet entered one.
  def delivery_address
    @delivery_address ||=
      # Avoid unnecessary database query.
      session[:delivery_address_id] && Address.find_by(id: session[:delivery_address_id])
  end

  def set_shipping_amount
    @shipping_amount = shipping_amount
    @shipping_vat_amount = shipping_vat_amount
    @shipping_quote_needed = shipping_quote_needed?
  end

  # Calculates shipping amount based on whether shipping is applicable to any
  # products in the basket.
  def shipping_amount
    shipping_calculator.amount
  end

  def shipping_vat_amount
    shipping_calculator.vat_amount
  end

  def shipping_quote_needed?
    shipping_calculator.quote_needed?
  end

  def shipping_calculator
    @shipping_calculator ||=
      ShippingCalculator.new(
        shipping_class: shipping_class,
        basket: basket,
        delivery_date: delivery_date
      )
  end
end
