class Payments::YorkshirePaymentsController < PaymentsController
  skip_before_action :verify_authenticity_token, :protect_staging_website

  def callback
    @payment = Payment.new(
      service_provider: 'Yorkshire Payments',
      amount: params[:amountReceived] || '0',
      cart_id: params[:transactionUnique],
      currency: params[:currencyCode],
      installation_id: website.yorkshire_payments_merchant_id,
      test_mode: test_mode?,
      transaction_id: params[:transactionID],
    )

    if params[:responseCode] == '0'
      @payment.accepted = @payment.transaction_status = true
      clean_up
    end

    @payment.save
    render html: 'success'
  end

  def redirect
    redirect_to receipt_orders_path
  end

  private

    def test_mode?
      ['101380', '101381'].include?(website.yorkshire_payments_merchant_id)
    end
end
