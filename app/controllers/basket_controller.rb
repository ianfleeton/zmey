class BasketController < ApplicationController
  before_filter :find_basket
  
  before_filter :require_delivery_address, :only => 'place_order'
  before_filter :require_order, :only => 'select_payment_method'

  def index
  end

  def add
    product = Product.find_by_id_and_website_id(params[:product_id], @w.id)
    if product.nil?
      flash[:notice] = "Oops, we can't add that product to the basket."
      redirect_to request.referrer and return
    end
    quantity = params[:quantity].to_i
    quantity = 1 if quantity < 1
    item = BasketItem.find_by_basket_id_and_product_id(@basket.id, product.id)
    if item
      item.quantity += quantity
    else
      item = BasketItem.new(
        :basket_id => @basket.id,
        :product_id => product.id,
        :quantity => quantity)
    end
    item.save
    flash[:notice] = 'Added to basket'
    redirect_to request.referrer    
  end
  
  def update
    update_quantities if params[:update_quantities]
    remove_item if params[:remove_item]
    redirect_to :action => 'checkout' and return if params[:checkout]
    flash[:notice] = 'Basket updated'
    redirect_to :action => 'index'
  end
  
  def checkout
    redirect_to :action => 'index' and return if @basket.basket_items.empty?

    @address = nil
    @address = Address.find_by_id(session[:address_id]) if session[:address_id]
    @address = Address.new if @address.nil?
  end

  def place_order
    @order = Order.new
    @order.user_id = @current_user.id if logged_in?
    @order.copy_address @address
    @order.status = Order::WAITING_FOR_PAYMENT
    @order.save!
    session[:order_id] = @order.id
    redirect_to :action => 'select_payment_method'
  end

  def select_payment_method
  end
  
  protected

  # get valid order or send user back to checkout
  def require_order
    @order = session[:order_id] ? Order.find_by_id(session[:order_id]) : nil
    if @order.nil?
      flash[:notice] = "We couldn't find an order for you."
      redirect_to :action => 'checkout'
    end
  end

  # get valid delivery address or send user back to checkout
  def require_delivery_address
    @address = session[:address_id] ? Address.find_by_id(session[:address_id]) : nil
    redirect_to :action => 'checkout' if @address.nil?
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
end
