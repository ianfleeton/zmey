class Admin::ApiKeysController < Admin::AdminController
  def index
    @api_keys = current_user.api_keys
  end
end
