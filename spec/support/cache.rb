# Keeps rate limit counts from leaking between examples.
RSpec.configure do |config|
  config.before { Rails.cache.clear }
end
