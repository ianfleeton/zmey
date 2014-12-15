class Admin::CountriesController < Admin::AdminController
  before_action :find_country, only: [:edit, :update, :destroy]

  def index
    @countries = Country.order('name')
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(country_params)

    if @country.save
      redirect_to admin_countries_path, notice: 'Saved.'
    else
      render :new
    end
  end

  def update
    if @country.update_attributes(country_params)
      flash[:notice] = "Saved."
      redirect_to admin_countries_path
    else
      render :edit
    end
  end

  def destroy
    if @country.addresses.length > 0
      flash[:notice] = 'This country cannot be removed as there are addresses that refer to this country.'
    elsif @country.delivery_orders.length > 0
      flash[:notice] = 'This country cannot be removed as there are orders that refer to this country.'
    else
      @country.destroy
      flash[:notice] = "Country deleted."
    end
    redirect_to admin_countries_path
  end

  protected

  def find_country
    @country = Country.find_by(id: params[:id])
  end

  def country_params
    params.require(:country).permit(:iso_3166_1_alpha_2, :name, :shipping_zone_id)
  end
end
