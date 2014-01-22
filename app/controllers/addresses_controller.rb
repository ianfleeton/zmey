class AddressesController < ApplicationController
  def new
    @address = Address.new
  end

  def edit
    # get a valid address from the session; if not send the user to new
    @address = session[:address_id] ? Address.find_by(id: session[:address_id]) : nil
    redirect_to action: 'new' and return if @address.nil?
  end

  def create
    @address = Address.new(address_params)
    if logged_in?
      @address.user_id = @current_user.id
    end

    if @address.save
      flash[:notice] = "Saved address."
      session[:address_id] = @address.id
      redirect_to controller: 'basket', action: 'checkout'
    else
      render :new
    end
  end
  
  def update
    @address = Address.find(params[:id])
    if session[:address_id] && session[:address_id] == @address.id
      if @address.update_attributes(address_params)
        flash[:notice] = 'Address updated.'
        redirect_to controller: 'basket', action: 'checkout'
      else
        render :edit
      end
    else
      # shouldn't happen usually to regular users
      flash[:notice] = "Something's wrong with that address. Please create a new one."
      redirect_to action: 'new'
    end
  end

  private

    def address_params
      params.require(:address).permit(:address_line_1, :address_line_2, :country_id, :county, :email_address, :full_name, :phone_number, :postcode, :town_city)
    end
end
