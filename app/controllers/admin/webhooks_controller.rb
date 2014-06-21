class Admin::WebhooksController < Admin::AdminController
  before_action :admin_required

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

  private

    def webhook_params
      params.require(:webhook).permit(:event, :url)
    end
end
