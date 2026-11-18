# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:suite) do
    Stripe.api_key = if ENV["FULL_NETWORK_ACCESS"] == "1"
      # Talks to Stripe for real, so needs a real test mode key.
      ENV["STRIPE_TEST_API_KEY"].presence || Rails.application.credentials.stripe_api_key
    else
      # Stripe requests are stubbed with WebMock, but the Stripe client refuses
      # to send a request without an API key. Use a dummy key so specs don't
      # depend on decrypting real credentials.
      "sk_test_dummy"
    end
  end
end
