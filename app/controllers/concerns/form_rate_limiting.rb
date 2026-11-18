# Limits how often forms that sign in, send email or create records can be
# submitted, to slow down password guessing and abuse of the forms.
#
# Counts are kept in Rails.cache, which is Solid Cache in production.
module FormRateLimiting
  extend ActiveSupport::Concern

  class_methods do
    # Allows +to+ submissions of the +only+ actions per +within+ period for
    # each client IP address and, when +per_email+ is given, also for each
    # email address in params[per_email].
    def limit_submissions(only:, to:, within:, per_email: nil)
      rate_limit(
        to: to, within: within, only: only, name: "ip",
        with: -> { submission_rate_limited }
      )
      return unless per_email

      rate_limit(
        to: to, within: within, only: only, name: "email",
        by: -> { params.dig(*Array(per_email)).to_s.strip.downcase },
        with: -> { submission_rate_limited }
      )
    end
  end

  private

  def submission_rate_limited
    flash[:notice] = I18n.t("rate_limited")
    redirect_back(fallback_location: root_path)
  end
end
