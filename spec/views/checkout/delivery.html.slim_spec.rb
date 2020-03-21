require "rails_helper"

RSpec.describe "checkout/delivery.html.slim", type: :view do
  HIDDEN_PARAMS = {email_address: "ea", full_name: "fn", phone_number: "12"}
  let(:address) { Address.new(HIDDEN_PARAMS) }

  before do
    assign(:address, address)
    render
  end

  it "has a form to save details" do
    expect(rendered).to have_selector "form[action='#{save_delivery_details_path}'][method='post']"
  end

  [
    "address_line_1", "address_line_2", "town_city", "county", "postcode"
  ].each do |component|
    it "has a field for #{component}" do
      expect(rendered).to have_selector "input[name='address[#{component}]']"
    end
  end

  HIDDEN_PARAMS.each do |k, v|
    it "has a hidden field for #{k} with value #{v}" do
      expect(rendered).to have_selector "input[type='hidden'][name='address[#{k}]'][value='#{v}']", visible: false
    end
  end

  it "has a select box for country" do
    expect(rendered).to have_selector "select[name='address[country_id]']"
  end

  it "only lists shipping countries" do
    zone = FactoryBot.create(:shipping_zone)
    ship_to = FactoryBot.create(:country, shipping_zone: zone)
    no_ship = FactoryBot.create(:country)
    render
    expect(rendered).to have_selector "select[name='address[country_id]'] option[value='#{ship_to.id}']"
    expect(rendered).not_to have_selector "select[name='address[country_id]'] option[value='#{no_ship.id}']"
  end

  it "has a submit button" do
    expect(rendered).to have_selector "input[type='submit']"
  end
end
