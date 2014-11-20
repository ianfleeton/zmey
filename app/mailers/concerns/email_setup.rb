module EmailSetup
  extend ActiveSupport::Concern

  included do
    after_action :set_delivery_options
  end

  def set_delivery_options
    if @website.smtp_active?
      mail.delivery_method.settings.merge! @website.smtp_settings
    end
  end
end
