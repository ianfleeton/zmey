module ResetBasket
  extend ActiveSupport::Concern

  # Empties the basket for the given order and removes any coupons stored in
  # the session.
  #
  # Many actions using this method will be invoked by a remote payments
  # system which means that coupons won't be cleared in these cases.
  def reset_basket(order)
    order.empty_basket
    session[:coupons] = nil
  end
end
