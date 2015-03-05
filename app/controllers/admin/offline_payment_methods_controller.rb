class Admin::OfflinePaymentMethodsController < Admin::AdminController
  def index
    @offline_payment_methods = OfflinePaymentMethod.order('name')
  end
end
