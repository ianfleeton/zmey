class Admin::ApiKeysController < Admin::AdminController
  skip_before_action :admin_or_manager_required, only: [:retrieve]

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
      redirect_to admin_api_keys_path, notice: I18n.t("controllers.admin.api_keys.create.flash.created")
    else
      render :new
    end
  end

  def retrieve
    user = authenticate_with_http_basic { |u, p| User.authenticate(u, p) }
    if user
      @api_key = ApiKey.find_by(user_id: user.id, name: params[:name])
      if @api_key
        render formats: :json
      else
        head :not_found unless @api_key
      end
    else
      head :unauthorized
    end
  end

  private

  def api_key_params
    params.require(:api_key).permit(:name)
  end
end
