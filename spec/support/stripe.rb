# frozen_string_literal: true

# Stripe requests are stubbed with WebMock, but the Stripe client refuses to
# send a request without an API key. Use a dummy key so specs don't depend on
# decrypting real credentials.
RSpec.configure do |config|
  config.before(:suite) do
    Stripe.api_key = "sk_test_dummy"
  end
end
