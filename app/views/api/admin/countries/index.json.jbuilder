json.countries(@countries) do |country|
  json.id country.id
  json.href api_admin_country_url(country)
  json.name country.name
end
