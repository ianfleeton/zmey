module Administrators
  # Devise sign in for administrators, with rate limiting.
  class SessionsController < Devise::SessionsController
    include FormRateLimiting

    limit_submissions only: :create, to: 10, within: 5.minutes,
      per_email: [:administrator, :email]
  end
end
