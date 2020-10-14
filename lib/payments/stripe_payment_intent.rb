# frozen_string_literal: true

module Payments
  # Creates charges to a customer's funding source (identitified by a token)
  # for the total amount of an order using the Stripe payment gateway.
  class StripePaymentIntent
    STRIPE_WEBHOOK = "Stripe Webhook"

    attr_reader :error, :payment

    def initialize(order:, payment_method:, idempotency_key:, payment_intent_id: nil, payment_intent: nil, customer: nil, stored: false)
      @order = order
      @payment_intent = payment_intent
      @payment_intent_id = payment_intent_id
      @payment_method = payment_method
      @idempotency_key = idempotency_key
      @customer = customer
      @stored = stored
    end

    def attempt(service_provider: "Stripe Web")
      return if @order.payment_received?

      begin
        @payment_intent ||= find_or_create_intent
      rescue ::Stripe::APIError, ::Stripe::IdempotencyError,
        ::Stripe::CardError, ::Stripe::InvalidRequestError => exception
        @error = exception
        add_order_comment(service_provider: service_provider)
        return
      end
      create_payment(service_provider: service_provider) if succeeded?
    end

    def confirm(service_provider: "Stripe Web")
      @payment_intent = ::Stripe::PaymentIntent.confirm(@payment_intent_id)
      create_payment(service_provider: service_provider) if succeeded?
    end

    def requires_action?
      status == "requires_action" && @payment_intent.next_action.type == "use_stripe_sdk"
    end

    def requires_confirmation?
      status == "requires_confirmation"
    end

    def succeeded?
      status == "succeeded"
    end

    def client_secret
      @payment_intent.client_secret
    end

    def status
      @payment_intent.status
    end

    def create_mobile_intent
      create_intent(confirm: false, confirmation_method: "automatic", ignore_webhook: false)
    end

    def create_webhook_payment
      create_payment(service_provider: STRIPE_WEBHOOK)
    end

    def log_failed_payment
      create_payment(service_provider: STRIPE_WEBHOOK, accepted: false)
      @error = @payment_intent.last_payment_error
      add_order_comment(service_provider: STRIPE_WEBHOOK)
    end

    def ignore_webhook?
      @payment_intent.respond_to?(:metadata) && @payment_intent.metadata["ignore_webhook"] == "true"
    end

    private

    def find_or_create_intent
      if @payment_intent_id
        ::Stripe::PaymentIntent.retrieve(@payment_intent_id)
      else
        create_intent(confirm: true, confirmation_method: "manual", ignore_webhook: true)
      end
    end

    def create_payment(service_provider:, accepted: true)
      transaction_id = @payment_intent.id

      if accepted
        return if Payment.exists?(transaction_id: transaction_id, accepted: true)
        order_id = nil
      else
        order_id = @order.id
      end

      @payment = Payment.create!(
        order_id: order_id,
        cart_id: @order.order_number,
        amount: @order.total,
        accepted: accepted,
        service_provider: service_provider,
        transaction_id: transaction_id,
        raw_auth_message: @payment_intent.to_s,
        apple_pay: apple_pay?,
        stored: apple_pay? || @stored
      )
    end

    def create_intent(confirm:, confirmation_method:, ignore_webhook:)
      @payment_intent = ::Stripe::PaymentIntent.create(
        {
          payment_method: @payment_method,
          amount: (@order.total * 100).to_i,
          currency: "gbp",
          confirmation_method: confirmation_method,
          confirm: confirm,
          description: @order.order_number,
          customer: @customer.try(:customer_id),
          # Stripe metadata values are strings -- use #to_s to be explicit
          metadata: {
            ignore_webhook: ignore_webhook.to_s
          }
        },
        idempotency_key: @idempotency_key
      )
    end

    def add_order_comment(service_provider:)
      @order.order_comments << OrderComment.new(
        comment: "#{service_provider} payment failed: #{@error.message}"
      )
    end

    def apple_pay?
      if @payment_intent.source
        @payment_intent.source.tokenization_method == "apple_pay"
      else
        @payment_intent.charges.any? { |c| c.payment_method_details&.card&.wallet&.type == "apple_pay" }
      end
    rescue NoMethodError
      false
    end
  end
end
