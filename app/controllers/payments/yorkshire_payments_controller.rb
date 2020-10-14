class Payments::YorkshirePaymentsController < PaymentsController
  skip_before_action :verify_authenticity_token, :protect_staging_website

  def callback
    @payment = Payment.new(
      service_provider: "Yorkshire Payments",
      amount: amount_received,
      cart_id: params[:transactionUnique],
      currency: params[:currencyCode],
      installation_id: website.yorkshire_payments_merchant_id,
      test_mode: test_mode?,
      transaction_id: params[:transactionID]
    )

    s = YorkshirePayments::Signature.new(request.raw_post, website.yorkshire_payments_pre_shared_key)

    if params[:responseCode] == "0" && s.verify
      @payment.accepted = @payment.transaction_status = true
      finalize_order
    end

    @payment.save
    render html: "success"
  end

  def redirect
    redirect_to receipt_orders_path
  end

  private

  def amount_received
    if params[:amountReceived].present?
      "%.2f" % (params[:amountReceived].to_i / 100.0)
    else
      "0"
    end
  end

  def test_mode?
    ["101380", "101381"].include?(website.yorkshire_payments_merchant_id)
  end
end
