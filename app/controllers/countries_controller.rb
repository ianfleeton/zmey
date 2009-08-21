class CountriesController < ApplicationController
  before_filter :admin_required
  
  def bootstrap
    Country.destroy_all
    Country.new(:name => 'United Kingdom', :iso_3166_1_alpha_2 => 'GB').save
    flash[:notice] = 'Countries bootstrapped.'
    redirect_to '/'
  end
end
