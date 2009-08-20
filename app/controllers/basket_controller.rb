class BasketController < ApplicationController
  def index
  end

  def add
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
    session[:basket_id] = @basket
  end
end
