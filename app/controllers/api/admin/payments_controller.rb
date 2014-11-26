class Api::Admin::PaymentsController < Api::Admin::AdminController
  def index
    @payments = Payment.all
  end

  def show
    @payment = Payment.find_by(id: params[:id])
    render nothing: true, status: 404 unless @payment
  end
end
