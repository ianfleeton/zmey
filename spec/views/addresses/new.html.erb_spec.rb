require "rails_helper"

describe "addresses/new.html.erb" do
  before do
    assign(:address, Address.new)
  end

  it "has a dropdown of shipping countries" do
    allow(Country).to receive(:shipping).and_return [
      Country.new(id: 1, name: "United Kingdom")
    ]
    render
    expect(rendered).to have_selector("select#address_country_id", text: "United Kingdom")
  end
end
