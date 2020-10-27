# frozen_string_literal: true

module DeliveryDateConcerns
  extend ActiveSupport::Concern

  def valid_delivery_date?
    return true unless needs_delivery_date?
    delivery_dates_include?(delivery_date)
  end

  def remove_invalid_delivery_date
    if session[:delivery_date] && !valid_delivery_date?
      session[:delivery_date] = nil
    end
  end

  def update_delivery_date(date_str)
    if date_str.blank?
      session[:delivery_date] = nil
      return
    end

    begin
      date = Date.parse(date_str)
      session[:delivery_date] = date_str if delivery_dates_include?(date)
    rescue ArgumentError
    end
  end

  def needs_delivery_date?
    shipping_class.try(:choose_date?)
  end

  def delivery_dates_include?(date)
    delivery_dates.include?(date)
  end

  def delivery_date
    Date.parse(session[:delivery_date])
  rescue
  end

  def dispatch_date
    Shipping::DispatchDeliveryDate.dispatch_date(
      dispatch_delivery_spec, delivery_date
    )
  end

  def delivery_dates
    @delivery_dates ||= Shipping::DispatchDeliveryDate.delivery_dates(dispatch_delivery_spec)
  end

  def dispatch_delivery_spec
    Shipping::DispatchDeliverySpec.default(
      items: basket.basket_items, lead_time: basket.lead_time,
      shipping_class: shipping_class,
      cutoff: website.delivery_cutoff_hour
    )
  end
end
