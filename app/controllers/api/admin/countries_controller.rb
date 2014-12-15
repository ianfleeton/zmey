class Api::Admin::CountriesController < Api::Admin::AdminController
  def index
    @countries = Country.all
  end
end
