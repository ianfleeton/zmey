class Api::Admin::OrdersController < Api::Admin::AdminController
  def index
    @orders = website.orders
  end
end
