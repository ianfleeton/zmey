class Admin::OrdersController < ApplicationController
  before_action :admin_or_manager_required
  before_action :find_order, only: [:show, :destroy]

  layout 'admin'

  def index
    if params[:user_id]
      @orders = User.find(params[:user_id]).orders.where(website_id: @w.id)
    else
      @orders = @w.orders
    end
  end
  
  def show; end

  def purge_old_unpaid
    Order.purge_old_unpaid
    redirect_to admin_orders_path, notice: 'Old and unpaid orders purged.'
  end

  def destroy
    @order.destroy
    redirect_to admin_orders_path, notice: 'Order deleted.'
  end

  protected

  # get specific order
  def find_order
    @order = Order.find_by_id_and_website_id(params[:id], @w.id)
    if @order.nil?
      redirect_to orders_path, notice: 'Cannot find order.'
    end
  end
end
