class BasketController < ApplicationController
  before_filter :find_basket
  
  before_filter :require_delivery_address, :only => 'place_order'
  before_filter :invalidate_coupons, :only => [:index]
  before_filter :calculate_discounts, :only => [:index, :checkout, :place_order]

  def index
    @page = params[:page_id] ? Page.find_by_id(params[:page_id]) : nil
  end

  def add
    product = Product.find_by_id_and_website_id(params[:product_id], @w.id)
    if product.nil?
      flash[:notice] = "Oops, we can't add that product to the basket."
      redirect_to request.referrer and return
    end
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    feature_selections = get_feature_selections
    unless flash[:notice].nil?
      redirect_to request.referrer and return
    end

    @basket.add(product, feature_selections, quantity)
    add_additional_products

    flash[:notice] = 'Added to basket.'
    if params[:page_id].nil?
      redirect_to :action => 'index'
    else
      redirect_to :action => 'index', :page_id => params[:page_id]
    end
  end
  
  def update
    update_quantities if params[:update_quantities]
    remove_item if params[:remove_item]
    redirect_to :action => 'checkout' and return if params[:checkout]
    flash[:notice] = 'Basket updated.'
    redirect_to :action => 'index'
  end
  
  def checkout
    redirect_to :action => 'index' and return if @basket.basket_items.empty?

    @address = nil
    @address = Address.find_by_id(session[:address_id]) if session[:address_id]
    if @address.nil?
      @address = Address.new
      @address.country = Country.find_by_name_and_website_id('United Kingdom', @w.id)
      if logged_in?
        @address.user_id = @current_user.id
        @address.email_address = @current_user.email
        @address.full_name = @current_user.name
      end
    end
    
    @shipping_amount = shipping_amount
  end

  def place_order
    # Delete previous unpaid order, if any
    if session[:order_id] && @order = Order.find_by_id(session[:order_id])
      @order.destroy if @order.status == Order::WAITING_FOR_PAYMENT
    end

    @order = Order.new
    @order.website_id = @w.id
    @order.user_id = @current_user.id if logged_in?
    @order.copy_address @address

    unless params[:preferred_delivery_date].nil?
      @order.preferred_delivery_date = Date.strptime(params[:preferred_delivery_date],
        @w.preferred_delivery_date_settings.date_format)
      @order.preferred_delivery_date_prompt = @w.preferred_delivery_date_settings.prompt
      @order.preferred_delivery_date_format = @w.preferred_delivery_date_settings.date_format
    end

    @basket.basket_items.each do |i|
      @order.order_lines << OrderLine.new(
        :product_id => i.product.id,
        :product_sku => i.product.sku,
        :product_name => i.product.name,
        :product_price => i.product.price_ex_tax(i.quantity),
        :tax_amount => i.product.tax_amount(i.quantity) * i.quantity,
        :quantity => i.quantity,
        :line_total => i.product.price_ex_tax(i.quantity) * i.quantity,
        :feature_descriptions => i.feature_descriptions
      )
    end
    @discount_lines.each do |dl|
      @order.order_lines << OrderLine.new(
        :product_id => 0,
        :product_sku => 'DISCOUNT',
        :product_name => dl.name,
        :product_price => dl.price_adjustment,
        :tax_amount => dl.tax_adjustment,
        :quantity => 1,
        :line_total => dl.price_adjustment
      )
    end
    @order.status = Order::WAITING_FOR_PAYMENT
    @order.shipping_method = 'Standard Shipping'
    @order.shipping_amount = shipping_amount(0)
    # Store the basket with the order to clean up after payment.
    # Payment callbacks do not use session information.
    @order.basket_id = @basket.id
    @order.save!
    session[:order_id] = @order.id
    if @w.only_accept_payment_on_account?
      @order.status = Order::PAYMENT_ON_ACCOUNT
      @order.save
      OrderNotifier.notification(@w, @order).deliver
      @order.empty_basket(session)
      redirect_to :controller => 'orders', :action => 'receipt'
    else
      redirect_to :controller => 'orders', :action => 'select_payment_method'
    end
  end
  
  def purge_old
    Basket.purge_old
    flash[:notice] = 'Old baskets purged.'
    redirect_to :action => 'index'
  end

  def enter_coupon
    discount = Discount.find_by_coupon_and_website_id(params[:coupon_code].upcase, @w.id)
    if(discount.nil?)
      flash[:notice] = 'Sorry, your coupon code was not recognised.'
    else
      if session_contains_coupon? discount.coupon
        flash[:notice] = 'This coupon has already been applied.'
      else
        flash[:notice] = 'Your coupon has been applied to your basket.'
        add_coupon_to_session(discount.coupon)
        run_trigger_for_coupon_discount(discount)
      end
    end
    redirect_to :action => 'index'
  end

  def remove_coupon
    unless session[:coupons].nil?
      session[:coupons].subtract [params[:coupon_code].upcase]
    end
    flash[:notice] = 'Your coupon has been removed.'
    redirect_to :action => 'index'
  end

  protected

  def session_contains_coupon?(coupon)
    return false if session[:coupons].nil?
    return session[:coupons].include? coupon
  end

  def add_coupon_to_session(coupon)
    if session[:coupons].nil?
      session[:coupons] = Set.new
    end
    session[:coupons] << coupon
  end

  def run_trigger_for_coupon_discount(discount)
    if discount.reward_type.to_sym == :free_products
      add_free_products(discount.free_products_group.products)
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
      item = BasketItem.find_by_basket_id_and_product_id(@basket.id, product.id)
      unless item
        item = BasketItem.new(
          :basket_id => @basket.id,
          :product_id => product.id,
          :quantity => 1)
      end
      item.save
    end
    flash[:notice] += ' Free stuff has been added to your basket.'
  end

  def invalidate_coupons
    #flash[:now] = "Invalid coupon(s) have been removed from your basket. "
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
    find_delivery_address
    redirect_to :action => 'checkout' if @address.nil?
  end

  def find_delivery_address
    return if @address
    @address = session[:address_id] ? Address.find_by_id(session[:address_id]) : nil
  end

  def remove_item
    params[:remove_item].each_key do |id|
      BasketItem.destroy_all(:id => id, :basket_id => @basket.id)
    end
  end

  def update_quantities
    params[:qty].each_pair do |id,new_qty|
      new_qty = new_qty.to_i
      item = BasketItem.find_by_id_and_basket_id(id, @basket.id)
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

  def find_basket
    if session[:basket_id]
      @basket = Basket.find_by_id(session[:basket_id])
      create_basket if @basket.nil?
    else
      create_basket
    end
  end

  def create_basket
    @basket = Basket.new
    @basket.save
    session[:basket_id] = @basket.id
  end

  # calculates shipping amount based on the global website shipping amount
  # and whether shipping is applicable to any products in the basket
  # returns nil by default if there is no shipping_amount
  # set return_if_nil to 0, for example, if using in a calculation
  def shipping_amount(return_if_nil=nil)
    amount = 0.0

    if @basket.apply_shipping?
      find_delivery_address
      amount = @w.shipping_amount
      amount_by_address = calculate_shipping_from_address(@address)
      amount = amount_by_address.nil? ? amount : amount_by_address
    end

    amount += @basket.shipping_supplement

    (amount == 0.0) ? return_if_nil : amount
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
    basket_total = @basket.total(true)
    shipping = nil
    unless shipping_class.shipping_table_rows.empty?
      shipping_class.shipping_table_rows.each do |row|
        if basket_total >= row.trigger_value
          shipping = row.amount
        end
      end
    end
    shipping
  end

  def calculate_discounts
    @discount_lines = Array.new
    @w.discounts.each do |discount|
      if discount.coupon && session_contains_coupon?(discount.coupon)
        if discount.reward_type.to_sym == :free_products
          discount_free_products(discount.free_products_group.products)
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
end
