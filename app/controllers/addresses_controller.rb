class AddressesController < ApplicationController
  before_action :user_required, only: [:choose_delivery_address, :index]

  KNOWN_SOURCES = ['address_book', 'billing', 'delivery']

  ADDRESS_PARAMS_WHITELIST = [:address_line_1, :address_line_2,
      :country_id, :county, :email_address, :full_name, :label,
      :phone_number, :postcode, :town_city]

  def index
    if KNOWN_SOURCES.include?(params[:source])
      session[:source] = params[:source]
    else
      session[:source] = 'address_book'
    end
    @addresses = current_user.addresses
  end

  def choose_delivery_address
    @addresses = current_user.addresses
  end

  def select_for_delivery
    @address = Address.find_by(id: params[:id], user_id: current_user.id)
    session[:address_id] = @address.id if @address
    redirect_to checkout_path
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

      if session[:source] == 'billing'
        session[:address_id] = @address.id
      end

      redirect_to path_after_save
    else
      render :edit
    end
  end

  def destroy
    @address = Address.find_by(id: params[:id], user_id: current_user.id)
    if @address
      session[:address_id] = nil if session[:address_id] == @address.id
      @address.destroy
      flash[:notice] = I18n.t('controllers.addresses.destroy.deleted')
    end

    redirect_to path_after_destroy
  end

  private

    def address_params
      params.require(:address).permit(ADDRESS_PARAMS_WHITELIST)
    end

    def path_after_save
      {
        'address_book' => addresses_path,
        'billing'      => delivery_details_path,
        'delivery'     => confirm_checkout_path
      }.fetch(session[:source]) { checkout_path }
    end

    def path_after_destroy
      {
        'billing'  => choose_billing_address_addresses_path,
        'delivery' => choose_delivery_address_addresses_path
      }.fetch(session[:source]) { addresses_path }
    end
end
