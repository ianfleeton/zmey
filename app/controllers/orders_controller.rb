class OrdersController < ApplicationController
  before_filter :admin_required
  def index
    @orders = @w.orders
  end
end
