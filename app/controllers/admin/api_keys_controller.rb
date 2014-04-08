class Admin::ApiKeysController < Admin::AdminController
  def index
    @api_keys = current_user.api_keys
  end

  def new
    @api_key = ApiKey.new
  end

  def create
    @api_key = ApiKey.new(api_key_params)
    @api_key.user = current_user
    if @api_key.save
      redirect_to admin_api_keys_path, notice: I18n.t('controllers.admin.api_keys.create.flash.created')
    else
      render :new
    end
  end

  private

    def api_key_params
      params.require(:api_key).permit(:name)
    end
end
