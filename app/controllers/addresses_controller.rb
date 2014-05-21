class AddressesController < ApplicationController
  def index
    session[:return_to] = 'address_book'
    @addresses = current_user.addresses
  end

  def new
    @address = Address.new
  end

  def edit
    if logged_in?
      @address = Address.find_by(id: params[:id], user_id: current_user.id)
    else
      # get a valid address from the session
      @address = session[:address_id] ? Address.find_by(id: session[:address_id]) : nil
    end
    redirect_to action: 'new' and return if @address.nil?
  end

  def create
    @address = Address.new(address_params)
    if logged_in?
      @address.user_id = @current_user.id
    end

    if @address.save
      flash[:notice] = I18n.t('controllers.addresses.create.saved')
      session[:address_id] = @address.id
      redirect_to path_after_save
    else
      render :new
    end
  end
  
  def update
    if logged_in?
      @address = Address.find_by(id: params[:id], user_id: current_user.id)
    elsif session[:address_id] && session[:address_id] == params[:id]
      @address = Address.find_by(id: params[:id])
    end

    if @address.nil?
      # shouldn't happen usually to regular users
      flash[:notice] = I18n.t('controllers.addresses.update.invalid')
      redirect_to action: 'new' and return
    end

    if @address.update_attributes(address_params)
      flash[:notice] = I18n.t('controllers.addresses.update.updated')
      redirect_to path_after_save
    else
      render :edit
    end
  end

  private

    def address_params
      params.require(:address).permit(:address_line_1, :address_line_2,
      :country_id, :county, :email_address, :full_name, :label,
      :phone_number, :postcode, :town_city)
    end

    def path_after_save
      if session[:return_to] && session[:return_to] == 'address_book'
        addresses_path
      else
        checkout_path
      end
    end
end
