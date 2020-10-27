# frozen_string_literal: true

module CheckUpdatedBasket
  extend ActiveSupport::Concern

  private

  # Checks to see if the updated_at param is older than the loaded basket
  # updated_at value which, if it is, means that the someone (most likely the
  # customer) updated the basket in between this and the action we came from.
  # If so, the customer is redirected to a warning page.
  def check_updated_basket
    if params[:updated_at] && params[:updated_at].to_i < basket.updated_at.to_i
      redirect_to basket_updated_warning_path
    end
  end
end
