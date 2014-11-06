class Api::Admin::CountriesController < Api::Admin::AdminController
  def index
    @countries = website.countries
  end
end
