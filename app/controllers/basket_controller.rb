class BasketController < ApplicationController
  include ResetBasket
  include Shipping

  layout 'basket_checkout'

  before_action :require_delivery_address, only: [:place_order]

  before_action :update_shipping_class, only: [:update]
  before_action :set_shipping_class, only: [:index, :place_order]

  before_action :remove_invalid_discounts, only: [:index, :checkout, :place_order]
  before_action :calculate_discounts, only: [:index, :checkout, :place_order]

  before_action :update_customer_note, only: [:update, :checkout, :place_order]

  # Main basket page.
  #
  # <tt>@page</tt> is set if <tt>params[:page_id]</tt> is set. This can be used
  # in the view to allow the user to continue shopping on the previous page.
  def index
    @page = params[:page_id] ? Page.find_by(id: params[:page_id], website_id: website.id) : nil
  end

  def add
    go_back_to = request.referrer ? request.referrer : {action: 'index'}

    product = Product.find_by(id: params[:product_id])
    if product.nil?
      flash[:notice] = "Oops, we can't add that product to the basket."
      redirect_to go_back_to and return
    end
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    feature_selections = get_feature_selections
    unless flash[:notice].nil?
      redirect_to go_back_to and return
    end

    @basket.add(product, feature_selections, quantity)
    add_additional_products

    flash[:notice] = 'Added to basket.'
    if params[:page_id].nil?
      redirect_to basket_path
    else
      redirect_to basket_path, page_id: params[:page_id]
    end
  end

  # Update the quantities in the basket for one or more products. Products
  # need not be in the basket to begin with.
  #
  # FeatureSelections are not supported.
  #
  # Quantities are supplied in the +qty+ param, indexed by +product_id+.
  #
  #   <input type="text" name="qty[1]" value="0">
  #   <input type="text" name="qty[2]" value="3">
  def add_update_multiple
    if params[:qty].kind_of?(Hash)
      @basket.set_product_quantities(params[:qty])
    end
    redirect_to basket_path
  end

  def update
    update_quantities if params[:update_quantities]
    remove_item if params[:remove_item]
    redirect_to checkout_path and return if params[:checkout]
    flash[:notice] = 'Basket updated.'
    redirect_to basket_path
  end

  def place_order
    delete_previous_unpaid_order_if_any

    @order = Order.new
    @order.user_id = @current_user.id if logged_in?
    @order.ip_address = request.remote_ip
    @order.copy_delivery_address delivery_address

    # Copy delivery address into billing address as no billing address UI
    # ready yet.
    @order.copy_billing_address delivery_address

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

  def purge_old
    Basket.purge_old
    flash[:notice] = 'Old baskets purged.'
    redirect_to basket_path
  end

  def enter_coupon
    discount = Discount.find_by(coupon: params[:coupon_code].upcase)
    if(discount.nil?)
      flash[:notice] = 'Sorry, your coupon code was not recognised.'
    else
      if session_contains_coupon? discount.coupon
        flash[:notice] = 'This coupon has already been applied.'
      elsif !discount.currently_valid?
        flash[:notice] = 'This coupon is not currently valid.'
      else
        flash[:notice] = I18n.t('controllers.basket.enter_coupon.applied')
        add_coupon_to_session(discount.coupon)
        run_trigger_for_coupon_discount(discount)
      end
    end
    redirect_to basket_path
  end

  # Removes the coupon <tt>params[:coupon]</tt>, if present, from the user's
  # applied coupons.
  #
  # The user is redirected to their current basket.
  def remove_coupon
    unless session[:coupons].nil?
      session[:coupons].delete(params[:coupon_code].upcase)
    end
    flash[:notice] = I18n.t('controllers.basket.remove_coupon.removed')
    redirect_to basket_path
  end

  # Makes a clone of the current user's basket and sends an email to
  # <tt>params[:email_address]</tt> that contains a link to reload the saved
  # basket.
  #
  # The user is redirected to their current basket.
  def save_and_email
    cloned_basket = basket.deep_clone
    BasketMailer.saved_basket(website, params[:email_address], cloned_basket).deliver_now
    redirect_to basket_path, notice: I18n.t('controllers.basket.save_and_email.email_sent', email_address: params[:email_address])
  end

  # Loads a saved basket by its token provided in <tt>params[:token]</tt>.
  # This action would typically be invoked by following a link in an email
  # generated by +save_and_email+.
  #
  # The user is informed whether the basket was found or not. 
  #
  # The user is redirected to their current basket.
  def load
    saved_basket = Basket.find_by(token: params[:token])
    if saved_basket
      session[:basket_id] = saved_basket.id
      notice = I18n.t('controllers.basket.load.basket_loaded')
    else
      notice = I18n.t('controllers.basket.load.invalid_basket')
    end
    redirect_to basket_path, notice: notice
  end

  protected

  def delete_previous_unpaid_order_if_any
    if session[:order_id] && @order = Order.find_by(id: session[:order_id])
      @order.destroy if @order.status == Enums::PaymentStatus::WAITING_FOR_PAYMENT
    end
  end

  def session_contains_coupon?(coupon)
    return false if session[:coupons].nil?
    return session[:coupons].include? coupon
  end

  def add_coupon_to_session(coupon)
    if session[:coupons].nil?
      session[:coupons] = Array.new
    end
    session[:coupons] << coupon unless session[:coupons].include?(coupon)
  end

  def run_trigger_for_coupon_discount(discount)
    if discount.reward_type.to_sym == :free_products
      add_free_products(discount.product_group.products)
    end
  end

  def add_additional_products
    unless params[:additional_product].nil?
      params[:additional_product].each_pair do |additional_product_id, value|
        if value=="on"
          @basket.add(AdditionalProduct.find(additional_product_id).additional_product, [], 1)
        end
      end
    end
  end

  def add_free_products(products)
    products.each do |product|
      item = BasketItem.find_by(basket_id: @basket.id, product_id: product.id)
      unless item
        item = BasketItem.new(
          basket_id: @basket.id,
          product_id: product.id,
          quantity: 1)
      end
      item.save
    end
    flash[:notice] += ' Free stuff has been added to your basket.'
  end

  def remove_invalid_discounts
    return unless session[:coupons]

    session[:coupons].each do |coupon|
      discount = Discount.find_by(coupon: coupon)
      if !discount || !discount.currently_valid?
        session[:coupons].delete(coupon)
        flash[:now] = I18n.t('controllers.basket.remove_invalid_discounts.removed')
      end
    end
  end

  # Creates an array of FeatureSeletions based on the form input from
  # adding an item to the basket.
  #
  # It will set <tt>flash[:notice]</tt> if it encounters any errors.
  def get_feature_selections
    f_selections = Array.new
    unless params[:feature].nil?
      params[:feature].each_pair do |feature_id, value|
        feature = Feature.find(feature_id)
        f_selection = FeatureSelection.new
        f_selection.feature_id = feature.id
        case feature.ui_type
        when Feature::TEXT_FIELD
          f_selection.customer_text = value
          if value.empty? and feature.required?
            flash[:notice] = 'Please specify: ' + feature.name
            return
          end
        when Feature::DROP_DOWN
          f_selection.customer_text = ''
          f_selection.choice_id = value
          if value.empty? and feature.required?
            flash[:notice] = 'Please choose: ' + feature.name
            return
          end
        end
        f_selections << f_selection
      end
    end
    f_selections
  end

  # Get valid delivery address or send user back to checkout.
  def require_delivery_address
    redirect_to checkout_path unless delivery_address
  end

  def remove_item
    params[:remove_item].each_key do |id|
      BasketItem.destroy_all(id: id, basket_id: @basket.id)
    end
  end

  def update_quantities
    params[:qty].each_pair do |id,new_qty|
      new_qty = new_qty.to_i
      item = BasketItem.find_by(id: id, basket_id: @basket.id)
      if item
        if new_qty == 0
          item.destroy
        elsif new_qty > 0
          item.quantity = new_qty
          item.save
        end
      end
    end
  end

  def calculate_discounts
    @discount_lines = Array.new
    Discount.all.each do |discount|
      if discount.coupon && session_contains_coupon?(discount.coupon)
        if discount.reward_type.to_sym == :free_products
          discount_free_products(discount.product_group.products)
        elsif discount.reward_type.to_sym == :amount_off_order
          calculate_amount_off_order(discount)
        elsif discount.reward_type.to_sym == :percentage_off_order
          calculate_percentage_off_order(discount)
        elsif discount.reward_type.to_sym == :percentage_off
          calculate_percentage_off(discount)
        end
      end
    end
  end

  def discount_free_products products
    products.each do |product|
      @basket.basket_items.each do |basket_item|
        if product.id == basket_item.product_id
          discount_line = DiscountLine.new
          discount_line.name = 'Free ' + product.name
          discount_line.price_adjustment = -product.price_ex_tax
          discount_line.tax_adjustment = -product.tax_amount
          @discount_lines << discount_line
          break
        end
      end
    end
  end

  class EffectiveTotal
    def initialize(discount, basket)
      @discount, @basket = discount, basket
    end

    def ex_tax
      @ex_tax ||= if @discount.exclude_reduced_products?
        @basket.items_at_full_price.inject(0) { |sum, i| sum + i.line_total(false) }
      else
        @basket.total(false)
      end
    end

    def inc_tax
      @inx_tax ||= if @discount.exclude_reduced_products?
        @basket.items_at_full_price.inject(0) { |sum, i| sum + i.line_total(true) }
      else
        @basket.total(true)
      end
    end

    def tax_amount
      inc_tax - ex_tax
    end

    def tax_rate
      ex_tax > 0 ? inc_tax / ex_tax : 0
    end
  end

  def calculate_amount_off_order(discount)
    effective_total = EffectiveTotal.new(discount, @basket)

    if effective_total.ex_tax >= discount.threshold && effective_total.ex_tax > 0
      discount_line = DiscountLine.new
      discount_line.name = discount.name
      discount_line.price_adjustment = -discount.reward_amount / effective_total.tax_rate
      discount_line.tax_adjustment = - discount.reward_amount - discount_line.price_adjustment
      @discount_lines << discount_line
    end
  end

  def calculate_percentage_off_order(discount)
    effective_total = EffectiveTotal.new(discount, @basket)

    if effective_total.ex_tax >= discount.threshold && effective_total.ex_tax > 0
      discount_line = DiscountLine.new
      discount_line.name = discount.name
      discount_line.price_adjustment = -(discount.reward_amount / 100.0) * effective_total.ex_tax
      discount_line.tax_adjustment = -(discount.reward_amount / 100.0) * effective_total.tax_amount
      @discount_lines << discount_line
    end
  end

  def calculate_percentage_off(discount)
    @basket.basket_items.each do |basket_item|
      if discount.product_group.nil? || discount.product_group.products.include?(basket_item.product)
        discount_line = DiscountLine.new
        discount_line.name = "#{discount.name} - #{basket_item.product.name}"
        discount_line.price_adjustment = -(discount.reward_amount / 100.0) * basket_item.product.price_ex_tax
        discount_line.tax_adjustment = -(discount.reward_amount / 100.0) * basket_item.product.tax_amount
        @discount_lines << discount_line
      end
    end
  end

    def update_customer_note
      if params[:customer_note]
        @basket.update_attribute(:customer_note, params[:customer_note])
      end
    end

    def update_shipping_class
      shipping_class = ShippingClass.find_by(id: params[:shipping_class_id])
      session[:shipping_class_id] = shipping_class.id if shipping_class
    end
end
