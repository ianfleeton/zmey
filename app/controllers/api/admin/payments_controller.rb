class Api::Admin::PaymentsController < Api::Admin::AdminController
  def index
    @payments = Payment.all
  end

  def show
    @payment = Payment.find_by(id: params[:id])
    head 404 unless @payment
  end

  def create
    @payment = Payment.new(payment_params)
    if params[:payment][:order_id].blank? || !Order.exists?(id: params[:payment][:order_id])
      @payment.errors.add(:base, "Order does not exist.")
    end
    if @payment.errors.any? || !@payment.save
      render json: @payment.errors.full_messages, status: :unprocessable_entity
    end
  end

  def destroy
    if @payment = Payment.find_by(id: params[:id])
      @payment.destroy
      head 204
    else
      head 404
    end
  end

  private

  def payment_params
    params.require(:payment).permit(
      :accepted,
      :amount,
      :order_id,
      :raw_auth_message,
      :service_provider
    )
  end
end
