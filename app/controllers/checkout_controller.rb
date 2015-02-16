class CheckoutController < ApplicationController
  include Shipping
  include Discounts

  layout 'basket_checkout'

  before_action :require_basket, only: [:index, :billing, :delivery, :confirm]
  before_action :require_billing_and_delivery_addresses, only: [:confirm, :place_order]
  before_action :set_shipping_class, only: [:confirm, :place_order]
  before_action :set_shipping_amount, only: [:confirm]
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
    prepare_address(billing_address, 'billing', choose_billing_address_addresses_path)
  end

  def save_billing
    save_address(billing_address, :billing_address_id, 'billing') do |success, address|
      if success && params[:deliver_here] == '1'
        session[:delivery_address_id] = address.id
      end
    end
  end

  def delivery
    prepare_address(delivery_address, 'delivery', choose_delivery_address_addresses_path)
  end

  def save_delivery
    save_address(delivery_address, :delivery_address_id, 'delivery')
  end

  def confirm
    session[:source] = 'checkout'
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
    record_shipping

    @order.save!
    Webhook.trigger('order_created', @order)

    session[:order_id] = @order.id
    OrderNotifier.admin_waiting_for_payment(website, @order).deliver_now
    redirect_to controller: 'orders', action: 'select_payment_method'
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
        full_name: session[:name],
        phone_number: session[:phone],
        email_address: session[:email],
        country: Country.find_by(name: 'United Kingdom')
      )
    end

    def prepare_address(address, source, choose_address_path)
      redirect_to checkout_path and return if DETAILS_KEYS.any?{|k| session[k].blank?}

      if (@address = address).nil?
        if current_user.addresses.any?
          session[:source] = source
          redirect_to choose_address_path
        else
          @address = prefilled_address
        end
      end
    end

    def save_address(address, address_key, template)
      success =
        if (@address = address) && billing_and_delivery_different?
          @address.update_attributes(address_params.merge(user: current_user))
        else
          @address = Address.new(address_params.merge(user: current_user))
          if @address.save
            session[address_key] = @address.id
          end
        end

      yield success, address if block_given?

      if success
        advance_checkout
      else
        render template
      end
    end

    def billing_and_delivery_different?
      session[:billing_address_id].nil? || session[:billing_address_id] != session[:delivery_address_id]
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

    # Records shipping amount, tax and method into the order.
    def record_shipping
      record_shipping_method
      @order.shipping_amount = shipping_amount
      @order.shipping_tax_amount = shipping_tax_amount
    end

    def record_shipping_method
      if shipping_class
        @order.shipping_method = shipping_class.name
      else
        @order.shipping_method = 'Standard Shipping'
      end
    end
end
