module SuspendedShopping
  extend ActiveSupport::Concern

  included do
    before_action :bounce_suspended_shopping
  end

  private

    # Bounces customers to the home page when shopping is suspended.
    def bounce_suspended_shopping
      if website.shopping_suspended?
        redirect_to root_path, notice: website.shopping_suspended_message
      end
    end
end
