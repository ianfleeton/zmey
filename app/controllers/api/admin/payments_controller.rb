class Api::Admin::PaymentsController < Api::Admin::AdminController
  def index
    @payments = website.payments
  end
end
