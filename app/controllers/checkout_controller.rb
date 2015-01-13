class CheckoutController < ApplicationController
  include Shipping
  include Discounts

  layout 'basket_checkout'

  before_action :require_basket, only: [:index, :confirm]
  before_action :set_shipping_class, only: [:confirm]
  before_action :remove_invalid_discounts, only: [:confirm]
  before_action :calculate_discounts, only: [:confirm]

  DETAILS_KEYS = [:name, :email, :phone].freeze

  def index
    redirect_to billing_details_path if DETAILS_KEYS.all?{|k| session[k].present?}
  end

  def save_details
    DETAILS_KEYS.each {|k| session[k] = params[k]}
    redirect_to billing_details_path
  end

  def confirm
    session[:return_to] = 'checkout'
    @address = nil
    @address = Address.find_by(id: session[:address_id]) if session[:address_id]
    if @address.nil?
      if logged_in? && current_user.addresses.any?
        redirect_to choose_delivery_address_addresses_path
      else
        @address = Address.new
        @address.country = Country.find_by(name: 'United Kingdom')
        if logged_in?
          @address.user_id = @current_user.id
          @address.email_address = @current_user.email
          @address.full_name = @current_user.name
        end
      end
    end

    @shipping_amount = shipping_amount
    @shipping_tax_amount = shipping_tax_amount(@shipping_amount)
  end

  protected

    def require_basket
      redirect_to basket_path and return if basket.basket_items.empty?
    end
end
