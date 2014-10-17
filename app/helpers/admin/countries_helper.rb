module Admin::CountriesHelper
  def countries_options(website)
    website.countries.map {|c| [c.name, c.id]}
  end
end
