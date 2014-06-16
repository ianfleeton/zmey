class Admin::AddressesController < ApplicationController
  NESTED_ACTIONS = [:index]
  SHALLOW_ACTIONS = [:destroy, :edit, :update]
  before_action :set_address, only: SHALLOW_ACTIONS
  before_action :set_user, only: NESTED_ACTIONS

  layout 'admin'

  def index
    @addresses = @user.addresses
  end

  def edit
  end

  def update
    if @address.update_attributes(address_params)
      redirect_to admin_user_addresses_path(@address.user), notice: I18n.t('controllers.admin.addresses.update.flash.updated')
    else
      render :edit
    end
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

    def address_params
      params.require(:address).permit(:address_line_1, :address_line_2,
      :country_id, :county, :email_address, :full_name, :label,
      :phone_number, :postcode, :town_city)
    end
end

