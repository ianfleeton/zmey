class Admin::AddressesController < ApplicationController
  before_action :admin_or_manager_required
  before_action :set_user

  layout 'admin'

  def index
    @addresses = @user.addresses
  end

  private

    def set_user
      @user = User.find_by(id: params[:user_id], website: website)
      not_found unless @user
    end
end

