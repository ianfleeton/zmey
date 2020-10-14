class Payment < ActiveRecord::Base
  # Associations
  belongs_to :order, optional: true

  # ActiveRecord callbacks
  before_save :cancel_double_paypal_payments
  after_save :notify_order

  def notify_order
    order.try(:payment_accepted, self) if accepted?
  end

  # PayPal payments arrive in two parts: IPN and regular callback. We only need
  # one of these to be accepted but we can't be sure in which order they will
  # arrive. When the second payment notification arrives, this method unaccepts
  # the IPN version.
  #
  # If this is the IPN payment then it may set itself to not accepted in which
  # case the order doesn't need to know. If this is a non-IPN PayPal payment
  # then the after_save callback will notify the order of the payment and
  # trigger a payments recalculation.
  def cancel_double_paypal_payments
    return unless order

    if service_provider == paypal_ipn
      unaccept_self_if_existing_paypal
    elsif /PayPal/.match?(service_provider)
      unaccept_previous_ipn
    end
  end

  def unaccept_self_if_existing_paypal
    matching_payments = order.payments
      .where(transaction_id: transaction_id)
      .where("service_provider LIKE '%PayPal%'")
    matching_payments = matching_payments.where("id != ?", id) if id
    self.accepted = false if matching_payments.any?
  end

  def unaccept_previous_ipn
    matching_payments = order.payments
      .where(transaction_id: transaction_id)
      .where(service_provider: paypal_ipn)
    matching_payments = matching_payments.where("id != ?", id) if id
    matching_payments.each do |payment|
      payment.update_columns(accepted: false, updated_at: Time.current)
    end
  end

  def order_number
    order.try(:order_number) || cart_id
  end

  def auth_code=(auth_code)
    if auth_code.present?
      self.transaction_id = "Auth code #{auth_code}"
    end
  end

  def paypal_ipn
    "PayPal (IPN)"
  end

  def paypal_ipn?
    service_provider == paypal_ipn
  end
end
