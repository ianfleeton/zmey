class BasketController < ApplicationController
  include Discounts
  include SuspendedShopping

  layout "basket_checkout"

  before_action :update_shipping_class, only: [:update]

  before_action :update_customer_note, only: [:update]

  # Main basket page.
  #
  # <tt>@page</tt> is set if <tt>params[:page_id]</tt> is set. This can be used
  # in the view to allow the user to continue shopping on the previous page.
  def index
    @page = params[:page_id] ? Page.find_by(id: params[:page_id]) : nil
  end

  def add
    go_back_to = request.referrer || {action: "index"}

    product = Product.find_by(id: params[:product_id])
    if product.nil?
      flash[:notice] = "Oops, we can't add that product to the basket."
      redirect_to(go_back_to) && return
    end
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1

    feature_selections = get_feature_selections
    unless flash[:notice].nil?
      redirect_to(go_back_to) && return
    end

    @basket.add(product, feature_selections, quantity)
    add_additional_products

    flash[:notice] = "Added to basket."
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
    if params[:qty].is_a?(Hash)
      @basket.set_product_quantities(params[:qty])
    end
    if request.xhr?
      @basket.reload
    else
      redirect_to basket_path
    end
  end

  def update
    update_quantities if params[:update_quantities]
    remove_item if params[:remove_item]
    redirect_to(checkout_path) && return if checking_out?
    if request.xhr?
      head 204
    else
      flash[:notice] = "Basket updated."
      redirect_to basket_path
    end
  end

  def purge_old
    Basket.purge_old
    flash[:notice] = "Old baskets purged."
    redirect_to basket_path
  end

  def enter_coupon
    discount = Discount.find_by(coupon: params[:coupon_code].upcase)
    if discount.nil?
      flash[:notice] = "Sorry, your coupon code was not recognised."
    elsif session_contains_coupon? discount.coupon
      flash[:notice] = "This coupon has already been applied."
    elsif !discount.currently_valid?
      flash[:notice] = "This coupon is not currently valid."
    else
      flash[:notice] = I18n.t("controllers.basket.enter_coupon.applied")
      add_coupon_to_session(discount.coupon)
      run_trigger_for_coupon_discount(discount)
    end
    redirect_to basket_path
  end

  # Removes the coupon <tt>params[:coupon]</tt>, if present, from the user's
  # applied coupons.
  #
  # The user is redirected to their current basket.
  def remove_coupon
    session[:coupons]&.delete(params[:coupon_code].upcase)
    flash[:notice] = I18n.t("controllers.basket.remove_coupon.removed")
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
    redirect_to basket_path, notice: I18n.t("controllers.basket.save_and_email.email_sent", email_address: params[:email_address])
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
      notice = I18n.t("controllers.basket.load.basket_loaded")
    else
      notice = I18n.t("controllers.basket.load.invalid_basket")
    end
    redirect_to basket_path, notice: notice
  end

  protected

  def add_coupon_to_session(coupon)
    if session[:coupons].nil?
      session[:coupons] = []
    end
    session[:coupons] << coupon unless session[:coupons].include?(coupon)
  end

  def run_trigger_for_coupon_discount(discount)
    if discount.reward_type.to_sym == :free_products
      add_free_products(discount.product_group.products)
    end
  end

  def add_additional_products
    params[:additional_product]&.each_pair do |additional_product_id, value|
      if value == "on"
        @basket.add(AdditionalProduct.find(additional_product_id).additional_product, [], 1)
      end
    end
  end

  def add_free_products(products)
    products.each do |product|
      item = BasketItem.find_by(basket_id: @basket.id, product_id: product.id)
      item ||= BasketItem.new(
        basket_id: @basket.id,
        product_id: product.id,
        quantity: 1
      )
      item.save
    end
    flash[:notice] += " Free stuff has been added to your basket."
  end

  # Creates an array of FeatureSeletions based on the form input from
  # adding an item to the basket.
  #
  # It will set <tt>flash[:notice]</tt> if it encounters any errors.
  def get_feature_selections
    f_selections = []
    params[:feature]&.each_pair do |feature_id, value|
      feature = Feature.find(feature_id)
      f_selection = FeatureSelection.new
      f_selection.feature_id = feature.id
      case feature.ui_type
      when Feature::TEXT_FIELD
        f_selection.customer_text = value
        if value.empty? && feature.required?
          flash[:notice] = "Please specify: " + feature.name
          return
        end
      when Feature::DROP_DOWN
        f_selection.customer_text = ""
        f_selection.choice_id = value
        if value.empty? && feature.required?
          flash[:notice] = "Please choose: " + feature.name
          return
        end
      end
      f_selections << f_selection
    end
    f_selections
  end

  def remove_item
    params[:remove_item].each_key do |id|
      BasketItem.destroy_all(id: id, basket_id: @basket.id)
    end
  end

  def update_quantities
    params[:qty].each_pair do |id, new_qty|
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

  def update_customer_note
    if params[:customer_note]
      @basket.update_attribute(:customer_note, params[:customer_note])
    end
  end

  def update_shipping_class
    shipping_class = ShippingClass.find_by(id: params[:shipping_class_id])
    session[:shipping_class_id] = shipping_class.id if shipping_class
  end

  def checking_out?
    params[:checkout] || params["checkout.x"]
  end
end
