class OrdersController < ApplicationController
  before_filter :admin_required, :only => [:index]

  before_filter :require_order, :only => [:select_payment_method, :receipt]

  def index
    @orders = @w.orders
  end

  def select_payment_method
  end

  def receipt
    redirect_to :controller => 'basket', :action => 'index' and return unless @order.payment_received?
  end

  def purge_old_unpaid
    Order.purge_old_unpaid
    flash[:notice] = 'Old and unpaid orders purged.'
    redirect_to :action => 'index'
  end

  protected

  # get valid order or send user back to checkout
  def require_order
    @order = Order.from_session session
    if @order.nil?
      flash[:notice] = "We couldn't find an order for you."
      redirect_to :controller => 'basket', :action => 'checkout'
    end
  end

end
