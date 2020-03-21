module EmailSetup
  extend ActiveSupport::Concern

  included do
    after_action :set_delivery_options
    after_action :set_mandrill_subaccount
  end

  def set_delivery_options
    if @website.smtp_active?
      mail.delivery_method.settings.merge! @website.smtp_settings
    end
  end

  def set_mandrill_subaccount
    if @website.mandrill_subaccount.present?
      headers["X-MC-Subaccount"] = @website.mandrill_subaccount
    end
  end
end
