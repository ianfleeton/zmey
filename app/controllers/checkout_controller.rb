class CheckoutController < ApplicationController
  include Shipping
  include Discounts

  layout 'basket_checkout'

  before_action :require_basket, only: [:index, :billing, :confirm]
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

  def billing
    redirect_to checkout_path and return if DETAILS_KEYS.any?{|k| session[k].blank?}

    if (@address = billing_address).nil?
      if current_user.addresses.any?
        session[:source] = 'billing'
        redirect_to choose_billing_address_addresses_path
      else
        @address = prefilled_address
      end
    end
  end

  def save_billing
    success =
      if @address = billing_address
        @address.update_attributes(address_params)
      else
        @address = Address.new(address_params)
        if @address.save
          session[:billing_address_id] = @address.id
        end
      end

    if success
      redirect_to delivery_details_path
    else
      render 'billing'
    end
  end

  def confirm
    session[:source] = 'checkout'
    @address = nil
    @address = Address.find_by(id: session[:address_id]) if session[:address_id]
    if @address.nil?
      if current_user.addresses.any?
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

    def billing_address
      @billing_address ||= Address.find_by(id: session[:billing_address_id])
    end

    def prefilled_address
      Address.new(
        user: current_user,
        full_name: session[:name],
        phone_number: session[:phone],
        email_address: session[:email],
        country: Country.find_by(name: 'United Kingdom')
      )
    end

    def address_params
      params.require(:address).permit(AddressesController::ADDRESS_PARAMS_WHITELIST)
    end
end
