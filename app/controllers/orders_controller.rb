class OrdersController < ApplicationController
  before_filter :admin_or_manager_required, :only => [:destroy]

  before_filter :find_order, :only => [:show, :destroy]
  before_filter :require_order, :only => [:select_payment_method, :receipt]
  before_filter :user_required, :only => [:index, :show]

  def index
    if admin_or_manager?
      @can_delete = true
      if params[:user_id]
        @orders = User.find(params[:user_id]).orders
      else
        @orders = @w.orders
      end
    else
      @can_delete = false
      @orders = @current_user.orders
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
      redirect_to :root, :notice => 'You do not have permission to view that order.'
    end
  end

  def purge_old_unpaid
    Order.purge_old_unpaid
    redirect_to :action => 'index', :notice => 'Old and unpaid orders purged.'
  end

  def destroy
    @order.destroy
    redirect_to :action => "index", :notice => "Order deleted."
  end

  protected

  # get valid order from current session or send user back to their basket
  def require_order
    @order = Order.from_session session
    if @order.nil?
      redirect_to({:controller => 'basket', :action => 'index'},
        :notice => "We couldn't find an order for you.")
    end
  end

  # get specific order
  def find_order
    @order = Order.find_by_id_and_website_id(params[:id], @w.id)
    if @order.nil?
      redirect_to :action => 'index', :notice => 'Cannot find order.'
    end
  end
end
