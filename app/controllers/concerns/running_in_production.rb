module RunningInProduction
  extend ActiveSupport::Concern

  included do
    helper_method :running_in_production?
  end

  # Returns truthy if this is a production website.
  def running_in_production?
    Rails.env.production?
  end
end
