require "rails_helper"

RSpec.describe "checkout/delivery", type: :view do
  HIDDEN_PARAMS = {full_name: "fn"}.freeze
  let(:address) { Address.new(HIDDEN_PARAMS) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(Website.new)
      allow(view).to receive(:basket).and_return(Basket.new)
    end
    assign(:address, address)
    render
  end

  it "has a form to save details" do
    expect(rendered).to have_selector(
      "form[action='#{save_delivery_details_path}'][method='post']"
    )
  end

  %w[
    county postcode phone_number mobile_number
  ].each do |component|
    it "has a field for #{component}" do
      expect(rendered).to have_selector "input[name='address[#{component}]']"
    end
  end

  it "has pattern validation for phone fields" do
    expect(rendered).to have_selector "input[name='address[phone_number]'][pattern='[0-9 ]{10,}']"
    expect(rendered).to have_selector "input[name='address[mobile_number]'][pattern='[0-9 ]{10,}']"
  end

  it "has fields for address components" do
    expect(rendered).to have_selector "input[name='address[address_line_1]']"
    expect(rendered).to have_selector "input[name='address[address_line_2]']"
    expect(rendered).to have_selector "input[name='address[address_line_3]']"
    expect(rendered).to have_selector "input[name='address[town_city]']"
  end

  HIDDEN_PARAMS.each do |k, v|
    it "has a hidden field for #{k} with value #{v}" do
      expect(rendered).to have_selector(
        "input[type='hidden'][name='address[#{k}]'][value='#{v}']",
        visible: false
      )
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
    expect(rendered).to have_selector(
      "select[name='address[country_id]'] option[value='#{ship_to.id}']"
    )
    expect(rendered).not_to have_selector(
      "select[name='address[country_id]'] option[value='#{no_ship.id}']"
    )
  end

  it "renders the delivery instructions partial" do
    render
    expect(response).to have_content "Delivery instructions"
  end

  it "has a submit button" do
    expect(rendered).to have_selector "input[type='submit']"
  end
end
