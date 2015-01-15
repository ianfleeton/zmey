class CheckoutController < ApplicationController
  include Shipping
  include Discounts

  layout 'basket_checkout'

  before_action :require_basket, only: [:index, :billing, :delivery, :confirm]
  before_action :set_shipping_class, only: [:confirm]
  before_action :remove_invalid_discounts, only: [:confirm]
  before_action :calculate_discounts, only: [:confirm]

  DETAILS_KEYS = [:name, :email, :phone].freeze

  def index
    advance_checkout
  end

  def details
  end

  def save_details
    DETAILS_KEYS.each {|k| session[k] = params[k]}
    advance_checkout
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
      advance_checkout
    else
      render 'billing'
    end
  end

  def delivery
    redirect_to checkout_path and return if DETAILS_KEYS.any?{|k| session[k].blank?}

    if (@address = delivery_address).nil?
      if current_user.addresses.any?
        session[:source] = 'delivery'
        redirect_to choose_delivery_address_addresses_path
      else
        @address = prefilled_address
      end
    end
  end

  def save_delivery
    success =
      if @address = delivery_address
        @address.update_attributes(address_params)
      else
        @address = Address.new(address_params)
        if @address.save
          session[:delivery_address_id] = @address.id
        end
      end

    if success
      advance_checkout
    else
      render 'delivery'
    end
  end

  def confirm
    redirect_to billing_details_path and return unless billing_address
    redirect_to delivery_details_path and return unless delivery_address

    session[:source] = 'checkout'
    @shipping_amount = shipping_amount
    @shipping_tax_amount = shipping_tax_amount(@shipping_amount)
  end

  protected

    def require_basket
      redirect_to basket_path and return if basket.basket_items.empty?
    end

    def advance_checkout
      {
        :has_checkout_details? => checkout_details_path,
        :billing_address       => billing_details_path,
        :delivery_address      => delivery_details_path
      }.each_pair do |condition, destination|
        redirect_to destination and return unless send(condition)
      end
      redirect_to confirm_checkout_path
    end

    def has_checkout_details?
      DETAILS_KEYS.all?{|k| session[k].present?}
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
