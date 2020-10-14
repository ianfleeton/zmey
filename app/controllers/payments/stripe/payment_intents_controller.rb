# frozen_string_literal: true

module Payments
  module Stripe
    # Creates debit/credit card charges using Stripe.
    class PaymentIntentsController < ::PaymentsController
      before_action :set_order

      def create
        payment_intent_id = params[:payment_intent_id]
        payment_method = params[:payment_method_id]
        customer = nil

        stored = params[:save] == "on" || params[:use_saved] == "on"

        if payment_method.present?
          begin
            if stored
              customer = Payments::StripeCustomer.new(current_user)
              if params[:save] == "on"
                customer.add_payment_method(payment_method)
              end
            else
              # Customer is not signed in so we reuse a stripe customer id if
              # present in the session, create a new Stripe customer, add the
              # tokenised card as a payment method, and store the stripe customer id again
              # in the session (in case this is newly created).
              #
              # We do this so that we can improve Stripe's Radar fraud detection.
              # Although we've stored the customer's card source, we don't provide
              # a way for them to reuse it like we do for signed in users.
              @order.stripe_customer_id ||= session[:stripe_customer_id]
              customer = Payments::StripeCustomer.new(@order)
              customer.add_payment_method(payment_method)
              session[:stripe_customer_id] = @order.stripe_customer_id
            end
          rescue ::Stripe::APIError, ::Stripe::IdempotencyError,
            ::Stripe::CardError => error
            attempt_failed(error)
            return
          end
        end

        intent = Payments::StripePaymentIntent.new(
          order: @order, payment_method: payment_method, customer: customer,
          payment_intent_id: payment_intent_id,
          idempotency_key: params[:idempotency_key], stored: stored
        )
        intent.attempt
        if (error = intent.error)
          attempt_failed(error)
          return
        end

        if intent.requires_confirmation?
          intent.confirm
          if (error = intent.error)
            attempt_failed(error)
            return
          end
        end

        if intent.succeeded?
          attempt_succeeded(intent)
        elsif intent.requires_action?
          attempt_requires_action(intent)
        else
          attempt_failed(StandardError.new("Invalid payment intent response status: #{intent.status}"))
        end
      end

      private

      def attempt_failed(error)
        ExceptionNotifier.notify_exception(
          error,
          env: request.env,
          data: {
            message: "Stripe charge creation error",
            order: @order
          }
        )

        render json: {error: "Payment failed: #{error.message}"}, status: 400
      end

      def attempt_succeeded(intent)
        @payment = intent.payment
        finalize_order
        render json: {success: true}, status: 200
      end

      def attempt_requires_action(intent)
        render json: {
          requires_action: true,
          payment_intent_client_secret: intent.client_secret
        }, status: 200
      end
    end
  end
end
