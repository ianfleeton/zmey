class Admin::OfflinePaymentMethodsController < Admin::AdminController
  def index
    @offline_payment_methods = OfflinePaymentMethod.order('name')
  end

  def new
    @offline_payment_method = OfflinePaymentMethod.new
  end

  def create
    @offline_payment_method = OfflinePaymentMethod.new(offline_payment_method_params)
    if @offline_payment_method.save
      redirect_to admin_offline_payment_methods_path, notice: I18n.t('controllers.admin.offline_payment_methods.create.flash.created')
    else
      render :new
    end
  end

  private

    def offline_payment_method_params
      params.require(:offline_payment_method).permit(:name)
    end
end
