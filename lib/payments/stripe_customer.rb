# frozen_string_literal: true

module Payments
  class StripeCustomer
    attr_reader :user

    # Param user can be a User or an Order: any object that has stripe_customer_id
    # and email attributes.
    def initialize(user)
      @user = user
    end

    def add_source(token)
      if existing_customer?
        attach_source(token, nil)
      else
        create_customer(token)
      end
    end

    def add_payment_method(payment_method_id)
      if existing_customer?
        attach_payment_method(payment_method_id)
      else
        create_customer(nil, payment_method_id)
      end
    end

    def customer_id
      user.stripe_customer_id
    end

    def existing_customer?
      customer_id.present?
    end

    def sources
      return [] unless existing_customer?

      retrieve_customer.sources.map { |s| ::Payments::StripeSource.new(s) }
    end

    def payment_methods
      return [] unless existing_customer?

      ::Stripe::PaymentMethod.list(customer: customer_id, type: "card").map { |pm| ::Payments::StripePaymentMethod.new(pm) }
    end

    def retrieve_customer
      @customer ||= ::Stripe::Customer.retrieve(customer_id)
    end

    private

    def create_customer(token, payment_method_id)
      customer = ::Stripe::Customer.create(
        email: user.email,
        payment_method: payment_method_id,
        source: token
      )
      user.stripe_customer_id = customer.id
      user.save
    end

    def attach_source(token)
      customer = retrieve_customer
      customer.sources.create(source: token)
    end

    def attach_payment_method(payment_method_id)
      customer = retrieve_customer
      ::Stripe::PaymentMethod.attach(payment_method_id,
        {
          customer: customer.id
        })
    end
  end
end
