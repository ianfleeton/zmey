module Admin::CountriesHelper
  def countries_options(website)
    Country.order("name").map { |c| [c.name, c.id] }
  end
end
