class CheckoutController < ApplicationController
  include SuspendedShopping
  include CheckUpdatedBasket
  include DeliveryDateConcerns

  layout "basket_checkout"

  helper_method :delivery_date

  before_action :check_updated_basket
  before_action :require_basket, only: [:index, :billing, :delivery, :confirm]
  before_action :require_billing_and_delivery_addresses, only: [:confirm]

  DETAILS_KEYS = [:name, :email, :mobile, :phone].freeze

  def index
    advance_checkout
  end

  def details
    session[:source] = "checkout/details"
    @unsafe_redirect_url = checkout_details_url
    fetch_missing_details_from_user if logged_in?
  end

  def fetch_missing_details_from_user
    {
      name: :name,
      email: :email,
      phone: :phone_number,
      mobile: :mobile_number
    }.each do |sess_key, method|
      session[sess_key] = current_user.send(method) if session[sess_key].blank?
    end
  end

  def save_details
    DETAILS_KEYS.each { |k| session[k] = params[k] }
    basket.update_details(session)
    advance_checkout
  end

  def billing
    prepare_address(billing_address, "billing", choose_billing_address_addresses_path)
  end

  def save_billing
    save_address(
      billing_address, :billing_address_id, "billing"
    ) do |success, address|
      deliver_to(address) if success && params[:deliver_here] == "1"
      choose_collection if params[:collection] == "1"
    end
  end

  # Attempts to set the delivery address to the given billing address. If the
  # address has a shipping zone then it is set as the delivery address in the
  # session and the user is redirected to enter delivery instructions. If the
  # address is not permitted for shipping then the user is directed back to
  # their billing details to try again or choose another option.
  def deliver_to(address)
    if address.shipping_zone
      session[:delivery_address_id] = address.id
      redirect_to delivery_instructions_path
    else
      flash[:notice] = I18n.t(
        "controllers.checkout.save_billing.cannot_ship_to_country"
      )
      redirect_to billing_details_path
    end
  end

  def choose_collection
    session[:shipping_class_id] = ShippingClass.collection.try(:id)
    basket.update_details(session)
    shipping_class!
  end

  def collect
    choose_collection
    redirect_to confirm_checkout_path
  end

  def delivery
    prepare_address(
      delivery_address, "delivery", choose_delivery_address_addresses_path
    )
    use_delivery_postcode_from_session
  end

  def use_delivery_postcode_from_session
    return unless @address&.new_record?

    @address.postcode = session[:delivery_postcode]
  end

  def save_delivery
    save_address(
      delivery_address, :delivery_address_id, "delivery"
    ) do |success, address|
      session[:delivery_postcode] = address.postcode if success
    end
    update_delivery_instructions
  end

  def delivery_instructions
  end

  def save_delivery_instructions
    update_delivery_instructions
    redirect_to checkout_path
  end

  def confirm
    session[:source] = "checkout"

    unless valid_delivery_date?
      flash[:alert] = "Please choose a valid delivery date."
      redirect_to basket_path
      return
    end

    prepare_order_for_payment

    cookies.signed[:order_id] = @order.id

    Webhook.trigger("order_created", @order)

    if website.send_pending_payment_emails?
      OrderNotifier.admin_waiting_for_payment(website, @order).deliver_now
    end

    prepare_payment_methods(@order)
  end

  def prepare_order_for_payment
    @order = Orders::OrderBuilder.build(cookies.signed[:order_id]) { |builder|
      # Adding order lines via basket contents and discounts must occur
      # first due to order lines reloading the order.
      builder.add_basket basket
      builder.add_discount_lines discount_lines

      builder.add_client_details(
        ip_address: request.remote_ip, user_agent: request.user_agent
      )
      builder.billing_address = billing_address || Address.placeholder
      builder.delivery_address = delivery_address || Address.placeholder
      builder.requires_delivery_address = delivery_address_required?
      builder.user = current_user
      builder.add_shipping_details(
        net_amount: shipping_amount, vat_amount: shipping_vat_amount,
        method: shipping_method,
        # we set the NEEDS_SHIPPING_QUOTE status at a later stage if it's
        # needed, not now as it will invalidate the basket
        quote_needed: false
      )
      builder.dispatch_date = dispatch_date
      builder.delivery_date = delivery_date
    }
    @order.update_estimated_delivery_date
    @order.save!
  end

  def prepare_payment_methods(order)
    prepare_cardsave if website.cardsave_active?
    prepare_sage_pay(order) if website.sage_pay_active?
  end

  # Returns <tt>true</tt> if there is no shipping class, or if the selected
  # shipping class doesn't require a delivery address.
  def delivery_address_required?
    !(shipping_class && !shipping_class.requires_delivery_address?)
  end

  def delivery_address_valid?
    delivery_address || !delivery_address_required?
  end

  def shipping_method
    shipping_class ? shipping_class.name : "Standard Shipping"
  end

  protected

  def require_basket
    redirect_to(basket_path) && return if basket.basket_items.empty?
  end

  def advance_checkout
    checkout_conditions.each_pair do |condition, destination|
      unless send(condition)
        redirect_to destination
        break
      end
    end

    redirect_to confirm_checkout_path unless performed?
  end

  def checkout_conditions
    {
      all_checkout_details?: checkout_details_path,
      billing_address: billing_details_path,
      delivery_address_valid?: delivery_details_path,
      shipping_class_valid?: delivery_details_path
    }
  end

  def all_checkout_details?
    DETAILS_KEYS.all? { |k| session[k].present? }
  end

  def billing_address
    @billing_address ||= Address.find_by(id: session[:billing_address_id])
  end

  def shipping_class_valid?
    return false unless shipping_class
    return true if shipping_class.collection?
    return false unless delivery_address
    expected_shipping_class?
  end

  def expected_shipping_class?
    sel = Shipping::Selection.new(
      session: session,
      option: nil,
      postcode: delivery_address.postcode,
      address: delivery_address,
      basket: basket
    )
    sel.update
    expected_shipping_class = sel.shipping_class
    return true if shipping_class == expected_shipping_class
    return false if expected_shipping_class.nil?
    update_shipping_method(expected_shipping_class)
    true
  end

  def update_shipping_method(new_shipping_class)
    session[:delivery_postcode] = delivery_address.postcode
    session[:shipping_class_id] = new_shipping_class.id
    flash[:notice] =
      "We have changed your shipping method to match your postcode."
  end

  def prefilled_address
    Address.new(
      full_name: session[:name],
      mobile_number: session[:mobile],
      phone_number: session[:phone],
      email_address: session[:email],
      country: Country.uk
    )
  end

  def prepare_address(address, source, choose_address_path)
    if required_details_missing?
      redirect_to checkout_path
      return
    end

    return if (@address = address)

    if current_user.addresses.any?
      redirect_to_choose_address(source, choose_address_path)
    else
      @address = prefilled_address
    end
  end

  def required_details_missing?
    !all_checkout_details?
  end

  def redirect_to_choose_address(source, choose_address_path)
    session[:source] = source
    redirect_to choose_address_path
  end

  def save_address(address, address_key, template)
    success = try_save_address(address, address_key)

    yield success, @address if block_given?

    save_address_next_step(success, template)
  end

  def try_save_address(address, address_key)
    if (@address = address) && billing_and_delivery_different?
      @address.update(address_params.merge(user: current_user))
    else
      @address = Address.new_or_reuse(
        address_params.merge(user_id: current_user.id)
      )

      session[address_key] = @address.id if @address.save
    end
  end

  def save_address_next_step(success, template)
    if success
      advance_checkout unless performed?
    else
      render template
    end
  end

  def update_delivery_instructions
    update_delivery_instructions_from_deliver_option
  end

  def update_delivery_instructions_from_deliver_option
    return if params[:deliver_option].blank?

    basket.delivery_instructions =
      if params[:deliver_option] == "Other"
        params[:deliver_other]
      else
        params[:deliver_option]
      end
    basket.save
  end

  def billing_and_delivery_different?
    session[:billing_address_id].nil? ||
      session[:billing_address_id] != session[:delivery_address_id]
  end

  def address_params
    params.require(:address).permit(
      AddressesController::ADDRESS_PARAMS_ALLOW_LIST
    )
  end

  # Get valid billing and delivery addresses or send user back to checkout.
  def require_billing_and_delivery_addresses
    redirect_to checkout_path unless billing_address && delivery_address_valid?
  end

  def prepare_cardsave(order)
    @cardsave_transaction_date_time = cardsave_transaction_date_time
    @cardsave_hash = cardsave_hash_pre(order)
  end

  def cardsave_transaction_date_time
    offset = Time.now.strftime "%z"
    Time.now.strftime "%Y-%m-%d %H:%M:%S " + offset[0..2] + ":" + offset[3..4]
  end

  def cardsave_hash_pre(order)
    plain = "PreSharedKey=" + website.cardsave_pre_shared_key
    plain = plain + "&MerchantID=" + website.cardsave_merchant_id
    plain = plain + "&Password=" + website.cardsave_password
    plain = plain + "&Amount=" + (order.total * 100).to_int.to_s
    plain += "&CurrencyCode=826"
    plain = plain + "&OrderID=" + order.order_number
    plain += "&TransactionType=SALE"
    plain = plain + "&TransactionDateTime=" + @cardsave_transaction_date_time
    plain = plain + "&CallbackURL=" + cardsave_callback_payments_url
    plain += "&OrderDescription=Web purchase"
    plain = plain + "&CustomerName=" + order.delivery_full_name
    plain = plain + "&Address1=" + order.delivery_address_line_1
    plain = plain + "&Address2=" + order.delivery_address_line_2
    plain += "&Address3="
    plain += "&Address4="
    plain = plain + "&City=" + order.delivery_town_city
    plain = plain + "&State=" + order.delivery_county
    plain = plain + "&PostCode=" + order.delivery_postcode
    plain += "&CountryCode=826"
    plain += "&CV2Mandatory=true"
    plain += "&Address1Mandatory=true"
    plain += "&CityMandatory=true"
    plain += "&PostCodeMandatory=true"
    plain += "&StateMandatory=true"
    plain += "&CountryMandatory=true"
    plain = plain + "&ResultDeliveryMethod=" + "POST"
    plain += "&ServerResultURL="
    plain = plain + "&PaymentFormDisplaysResult=" + "false"

    require "digest/sha1"
    Digest::SHA1.hexdigest(plain)
  end

  def prepare_sage_pay(order)
    sage_pay = SagePay.new(
      pre_shared_key: website.sage_pay_pre_shared_key,
      vendor_tx_code: order.order_number,
      amount: order.total,
      delivery_surname: order.delivery_full_name,
      delivery_firstnames: order.delivery_full_name,
      delivery_address: order.delivery_address_line_1,
      delivery_city: order.delivery_town_city,
      delivery_post_code: order.delivery_postcode,
      delivery_country: order.delivery_country ? order.delivery_country.iso_3166_1_alpha_2 : "GB",
      success_url: sage_pay_success_payments_url,
      failure_url: sage_pay_failure_payments_url
    )
    @crypt = sage_pay.encrypt
  end
end
