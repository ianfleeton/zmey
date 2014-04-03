class Api::Admin::OrdersController < ApplicationController
  before_action :admin_required # TODO: Replace with API authentication

  def index
    @orders = website.orders
  end
end
