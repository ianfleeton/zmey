# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Order.fast_delete_all
CarouselSlide.destroy_all
Page.destroy_all
Product.destroy_all
Website.destroy_all

website = Website.create!(
  country_id: 1, # FIXME as I am a circular dependency :-(
  domain: 'www.localhost',
  email: 'merchant@example.com',
  name: 'Shop',
  subdomain: 'local'
)

website.populate_countries!
Page.bootstrap(website)

home_page = Page.find_by(name: 'Home')

idevice = Product.create!(
  name: 'iDevice',
  sku: 'IDV13',
)

ProductPlacement.create!(
  page: home_page,
  product: idevice
)

admin = User.create!(
  admin: true,
  email: 'merchant@example.com',
  name: 'Alice Adams',
  password: 'secret',
  website: website
)

bob = User.create!(
  email: 'bob@example.com',
  name: 'Bob Brown',
  password: 'letmein',
  website: website
)

bob_home = Address.create!(
  address_line_1: '1 Somerset Road',
  country: website.countries.first,
  email_address: 'bob@example.org',
  full_name: 'Bob Brown',
  postcode: 'L0N D0N',
  town_city: 'London',
  user: bob
)
