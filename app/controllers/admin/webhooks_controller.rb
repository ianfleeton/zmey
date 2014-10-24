class Admin::WebhooksController < Admin::AdminController
  before_action :admin_required
  before_action :set_webhook, only: [:edit, :update]

  def index
    @webhooks = website.webhooks
  end

  def new
    @webhook = Webhook.new
  end

  def create
    @webhook = Webhook.new(webhook_params)
    @webhook.website = website

    if @webhook.save
      redirect_to admin_webhooks_path, notice: I18n.t('controllers.admin.webhooks.create.created')
    else
      render :new
    end
  end

  def edit; end

  def update
    if @webhook.update_attributes(webhook_params)
      redirect_to admin_webhooks_path, notice: 'Saved.'
    else
      render :edit
    end
  end

  private

    def webhook_params
      params.require(:webhook).permit(:event, :url)
    end

    def set_webhook
      @webhook = Webhook.find_by(id: params[:id], website_id: website.id)
    end
end
