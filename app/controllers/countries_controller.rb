class CountriesController < ApplicationController
  layout 'admin'
  before_filter :admin_or_manager_required
  before_filter :find_country, only: [:edit, :update, :destroy]

  def index
    @countries = @w.countries
  end

  def new
    @country = Country.new
  end

  def create
    @country = Country.new(country_params)
    @country.website_id = @w.id

    if @country.save
      redirect_to countries_path, notice: 'Saved.'
    else
      render action: 'new'
    end
  end

  def update
    if @country.update_attributes(country_params)
      flash[:notice] = "Saved."
      redirect_to countries_path
    else
      render action: 'edit'
    end
  end

  def destroy
    if @country.addresses.length > 0
      flash[:notice] = 'This country cannot be removed as there are addresses that refer to this country.'
    elsif @country.orders.length > 0
      flash[:notice] = 'This country cannot be removed as there are orders that refer to this country.'
    else
      @country.destroy
      flash[:notice] = "Country deleted."
    end
    redirect_to countries_path
  end

  protected

  def find_country
    @country = Country.find_by_id_and_website_id(params[:id], @w.id)
  end

  def country_params
    params.require(:country).permit(:iso_3661_alpha_2, :name, :shipping_zone_id)
  end
end
