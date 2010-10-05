class OrdersController < ApplicationController
  before_filter :admin_or_manager_required, :only => [:destroy]

  before_filter :find_order, :only => [:show, :destroy]
  before_filter :require_order, :only => [:select_payment_method, :receipt]
  before_filter :user_required, :only => [:show]

  def index
    if params[:user_id]
      @orders = User.find(params[:user_id]).orders
      @can_delete = false
    else
      @orders = @w.orders
      @can_delete = true
    end
  end
  
  def select_payment_method
  end

  def receipt
    redirect_to :controller => 'basket', :action => 'index' and return unless (@order.payment_received? or @order.status==Order::PAYMENT_ON_ACCOUNT)
    @google_ecommerce_tracking = true
  end
  
  def show
    if admin_or_manager? or @current_user.id==@order.user_id
      render :action => 'receipt'
    else
      flash[:notice] = 'You do not have permission to view that order.'
      redirect_to :root
    end
  end

  def purge_old_unpaid
    Order.purge_old_unpaid
    flash[:notice] = 'Old and unpaid orders purged.'
    redirect_to :action => 'index'
  end

  def destroy
    @order.destroy
    flash[:notice] = "Order deleted."
    redirect_to :action => "index"
  end

  protected

  # get valid order from current session or send user back to checkout
  def require_order
    @order = Order.from_session session
    if @order.nil?
      flash[:notice] = "We couldn't find an order for you."
      redirect_to :controller => 'basket', :action => 'checkout'
    end
  end

  # get specific order
  def find_order
    @order = Order.find_by_id_and_website_id(params[:id], @w.id)
    if @order.nil?
      flash[:notice] = 'Cannot find order.'
      redirect_to :action => 'index'
    end
  end
end
