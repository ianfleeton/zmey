class Api::Admin::PaymentsController < Api::Admin::AdminController
  def index
    @payments = website.payments
  end

  def show
    @payment = Payment.find_by(id: params[:id])
    render nothing: true, status: 404 unless @payment.try(:order).try(:website) == website
  end
end
