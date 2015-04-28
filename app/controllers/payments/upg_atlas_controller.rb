class Payments::UpgAtlasController < PaymentsController
  skip_before_action :verify_authenticity_token

  def callback
    @payment = Payment.new(
      service_provider: 'UPG Atlas',
      amount: params[:transactionamount],
      cart_id: params[:ordernumber],
      email: params[:cardholdersemail],
      installation_id: website.upg_atlas_sh_reference,
      name: params[:cardholdersname],
      telephone: params[:cardholderstelephonenumber],
      test_mode: params[:transactiontype] == 'test',
      transaction_time: params[:transactiontime],
    )

    if params[:transactionnumber].try(:length) == 8
      @payment.accepted = @payment.transaction_status = true
      @payment.transaction_id = params[:transactionnumber]
      clean_up
    end

    @payment.save
    render html: 'success'
  end
end
