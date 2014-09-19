class BasketController < ApplicationController
  include ResetBasket

  layout 'basket_checkout'

  before_action :require_delivery_address, only: [:place_order]
  before_action :remove_invalid_discounts, only: [:index, :checkout, :place_order]
  before_action :calculate_discounts, only: [:index, :checkout, :place_order]
  before_action :update_customer_note, only: [:update, :checkout, :place_order]

  def index
    @page = params[:page_id] ? Page.find_by(id: params[:page_id]) : nil
  end

  def add
    go_back_to = request.referrer ? request.referrer : {action: 'index'}

    product = Product.find_by(id: params[:product_id], website_id: @w.id)
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
    redirect_to action: 'checkout' and return if params[:checkout]
    flash[:notice] = 'Basket updated.'
    redirect_to basket_path
  end

  def checkout
    redirect_to basket_path and return if @basket.basket_items.empty?
    session[:return_to] = 'checkout'

    @address = nil
    @address = Address.find_by(id: session[:address_id]) if session[:address_id]
    if @address.nil?
      if logged_in? && current_user.addresses.any?
        redirect_to choose_delivery_address_addresses_path
      else
        @address = Address.new
        @address.country = Country.find_by(name: 'United Kingdom', website_id: @w.id)
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

  def place_order
    delete_previous_unpaid_order_if_any

    @order = Order.new
    @order.website_id = website.id
    @order.user_id = @current_user.id if logged_in?
    @order.ip_address = request.remote_ip
    @order.copy_delivery_address @address
    @order.customer_note = @basket.customer_note

    unless params[:preferred_delivery_date].nil?
      @order.preferred_delivery_date = Date.strptime(params[:preferred_delivery_date],
        @w.preferred_delivery_date_settings.date_format)
      @order.preferred_delivery_date_prompt = website.preferred_delivery_date_settings.prompt
      @order.preferred_delivery_date_format = website.preferred_delivery_date_settings.date_format
    end

    @basket.basket_items.each do |i|
      @order.order_lines << OrderLine.new(
        product_id: i.product.id,
        product_sku: i.product.sku,
        product_name: i.product.name,
        product_price: i.product.price_ex_tax(i.quantity),
        product_weight: i.product.weight,
        tax_amount: i.product.tax_amount(i.quantity) * i.quantity,
        quantity: i.quantity,
        feature_descriptions: i.feature_descriptions
      )
    end
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
    @order.status = Order::WAITING_FOR_PAYMENT
    @order.shipping_method = 'Standard Shipping'
    @order.shipping_amount = shipping_amount(0)
    @order.shipping_tax_amount = shipping_tax_amount(@order.shipping_amount)
    # Store the basket with the order to clean up after payment.
    # Payment callbacks do not use session information.
    @order.basket_id = @basket.id
    @order.save!
    session[:order_id] = @order.id
    if website.only_accept_payment_on_account?
      @order.status = Order::PAYMENT_ON_ACCOUNT
      @order.save
      OrderNotifier.notification(website, @order).deliver
      reset_basket(@order)
      redirect_to controller: 'orders', action: 'receipt'
    else
      OrderNotifier.admin_waiting_for_payment(website, @order).deliver
      redirect_to controller: 'orders', action: 'select_payment_method'
    end
  end

  def purge_old
    Basket.purge_old
    flash[:notice] = 'Old baskets purged.'
    redirect_to basket_path
  end

  def enter_coupon
    discount = Discount.find_by(coupon: params[:coupon_code].upcase, website_id: website.id)
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

  def remove_coupon
    unless session[:coupons].nil?
      session[:coupons].delete(params[:coupon_code].upcase)
    end
    flash[:notice] = I18n.t('controllers.basket.remove_coupon.removed')
    redirect_to basket_path
  end

  def save_and_email
    cloned_basket = basket.deep_clone
    BasketMailer.saved_basket(website, params[:email_address], cloned_basket).deliver
    redirect_to basket_path, notice: I18n.t('controllers.basket.save_and_email.email_sent', email_address: params[:email_address])
  end

  # Loads a saved basket by its token.
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
      @order.destroy if @order.status == Order::WAITING_FOR_PAYMENT
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
        puts "value=#{value}"
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
      discount = Discount.find_by(coupon: coupon, website_id: website.id)
      if !discount || !discount.currently_valid?
        session[:coupons].delete(coupon)
        flash[:now] = I18n.t('controllers.basket.remove_invalid_discounts.removed')
      end
    end
  end

  # Creates an array of FeatureSeletions based on the form input from
  # adding an item to the basket.
  # It will set flash[:notice] if it encounters any errors.
  def get_feature_selections
    f_selections = Array.new
    unless params[:feature].nil?
      params[:feature].each_pair do |feature_id, value|
        puts feature_id + ': ' + value
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

  # get valid delivery address or send user back to checkout
  def require_delivery_address
    @address = find_delivery_address
    redirect_to action: 'checkout' if @address.nil?
  end

  def find_delivery_address
    @address ||= session[:address_id] ? Address.find_by(id: session[:address_id]) : nil
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

  # calculates shipping amount based on the global website shipping amount
  # and whether shipping is applicable to any products in the basket
  # returns nil by default if there is no shipping_amount
  # set return_if_nil to 0, for example, if using in a calculation
  def shipping_amount(return_if_nil=nil)
    amount = 0.0

    if @basket.apply_shipping?
      @address = find_delivery_address
      amount = website.shipping_amount
      amount_by_address = calculate_shipping_from_address(@address)
      amount = amount_by_address.nil? ? amount : amount_by_address
    end

    amount += @basket.shipping_supplement

    (amount == 0.0) ? return_if_nil : amount
  end

  def shipping_tax_amount(shipping_amount_net)
    if shipping_amount_net && website.vat_number.present?
      Product::VAT_RATE * shipping_amount_net
    else
      0
    end
  end

  def calculate_shipping_from_address(address)
    if !address
      nil
    elsif !address.country
      nil
    elsif !address.country.shipping_zone
      nil
    elsif address.country.shipping_zone.shipping_classes.empty?
      nil
    else
      calculate_shipping_from_class(address.country.shipping_zone.shipping_classes.first)
    end
  end

  def calculate_shipping_from_class(shipping_class)
    case shipping_class.table_rate_method
    when 'basket_total'
      value = @basket.total(true)
    when 'weight'
      value = @basket.weight
    else
      raise 'Unknown table rate method'
    end

    shipping = nil

    unless shipping_class.shipping_table_rows.empty?
      shipping_class.shipping_table_rows.each do |row|
        if value >= row.trigger_value
          shipping = row.amount
        end
      end
    end

    shipping
  end

  def calculate_discounts
    @discount_lines = Array.new
    website.discounts.each do |discount|
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
end
