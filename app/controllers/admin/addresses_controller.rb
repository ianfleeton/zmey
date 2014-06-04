class Admin::AddressesController < ApplicationController
  NESTED_ACTIONS = [:index]
  SHALLOW_ACTIONS = [:destroy]
  before_action :admin_or_manager_required
  before_action :set_address, only: SHALLOW_ACTIONS
  before_action :set_user, only: NESTED_ACTIONS

  layout 'admin'

  def index
    @addresses = @user.addresses
  end

  def destroy
    @address.destroy
    redirect_to admin_user_addresses_path(@address.user), notice: I18n.t('controllers.admin.addresses.destroy.flash.destroyed')
  end

  private

    def set_address
      @address = Address.find_by(id: params[:id])
      not_found and return unless @address.try(:user).try(:website) == website
    end

    def set_user
      @user = User.find_by(id: params[:user_id], website: website)
      not_found unless @user
    end
end

