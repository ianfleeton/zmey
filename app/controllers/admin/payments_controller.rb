class Admin::PaymentsController < Admin::AdminController
  def new
    order = Order.find(params[:order_id])
    @payment = Payment.new(order: order, amount: order.outstanding_payment_amount)
  end

  def create
    @payment = Payment.new(payment_params.merge(accepted: true))
    if @payment.save
      redirect_to edit_admin_order_path(@payment.order)
    else
      render 'new'
    end
  end

  private

    def payment_params
      params.require(:payment).permit(:amount, :order_id, :raw_auth_message, :service_provider)
    end
end
