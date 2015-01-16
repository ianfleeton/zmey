class CheckoutController < ApplicationController
  include Shipping
  include Discounts
  include ResetBasket

  layout 'basket_checkout'

  before_action :require_billing_and_delivery_addresses, only: [:place_order]
  before_action :require_basket, only: [:index, :billing, :delivery, :confirm]
  before_action :set_shipping_class, only: [:confirm, :place_order]
  before_action :remove_invalid_discounts, only: [:confirm]
  before_action :calculate_discounts, only: [:confirm, :place_order]

  DETAILS_KEYS = [:name, :email, :phone].freeze

  def index
    advance_checkout
  end

  def details
    if logged_in?
      session[:name] = current_user.name if session[:name].blank?
      session[:email] = current_user.email if session[:email].blank?
    end
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

  def place_order
    delete_previous_unpaid_order_if_any

    @order = Order.new
    @order.user_id = @current_user.id if logged_in?
    @order.ip_address = request.remote_ip
    @order.copy_delivery_address delivery_address
    @order.copy_billing_address billing_address

    @order.customer_note = @basket.customer_note

    @order.record_preferred_delivery_date(
      website.preferred_delivery_date_settings,
      params[:preferred_delivery_date]
    )

    @order.add_basket(@basket)

    @discount_lines.each do |dl|
      @order.order_lines << OrderLine.new(
        product_id: 0,
        product_sku: 'DISCOUNT',
        product_name: dl.name,
        product_price: dl.price_adjustment,
        tax_amount: dl.tax_adjustment,
        quantity: 1
      )
    end
    @order.status = Enums::PaymentStatus::WAITING_FOR_PAYMENT
    @order.shipping_method = 'Standard Shipping'
    @order.shipping_amount = shipping_amount(0)
    @order.shipping_tax_amount = shipping_tax_amount(@order.shipping_amount)

    @order.save!
    Webhook.trigger('order_created', @order)

    session[:order_id] = @order.id
    if website.only_accept_payment_on_account?
      @order.status = Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
      @order.save
      OrderNotifier.notification(website, @order).deliver_now
      reset_basket(@order)
      redirect_to controller: 'orders', action: 'receipt'
    else
      OrderNotifier.admin_waiting_for_payment(website, @order).deliver_now
      redirect_to controller: 'orders', action: 'select_payment_method'
    end
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

    def delete_previous_unpaid_order_if_any
      if session[:order_id] && @order = Order.find_by(id: session[:order_id])
        @order.destroy if @order.status == Enums::PaymentStatus::WAITING_FOR_PAYMENT
      end
    end

    # Get valid billing and delivery addresses or send user back to checkout.
    def require_billing_and_delivery_addresses
      redirect_to checkout_path unless billing_address && delivery_address
    end
end
