# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Administrator.destroy_all
Order.fast_delete_all
Page.destroy_all
Product.destroy_all
User.destroy_all
Website.destroy_all

Country.populate!

website = Website.create!(
  country: Country.find_by(name: "United Kingdom"),
  domain: "www.localhost",
  email: "merchant@example.com",
  name: "Shop",
  show_vat_inclusive_prices: true,
  subdomain: "local",
  vat_number: "GB123456789"
)

Page.bootstrap(website)

home_page = Page.find_by(name: "Home")

idevice = Product.create!(
  name: "iDevice",
  price: BigDecimal("579.17"),
  sku: "IDV13",
  tax_type: Product::EX_VAT
)

ProductPlacement.create!(
  page: home_page,
  product: idevice
)

Administrator.create!(
  email: "merchant@example.com",
  name: "Alice Adams",
  password: "secret"
)

bob = User.create!(
  email: "bob@example.com",
  name: "Bob Brown",
  password: "topsecret"
)

Address.create!(
  address_line_1: "1 Somerset Road",
  country: Country.first,
  email_address: "bob@example.org",
  full_name: "Bob Brown",
  postcode: "L0N D0N",
  town_city: "London",
  user: bob
)
