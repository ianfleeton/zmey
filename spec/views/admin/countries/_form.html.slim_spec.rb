require "rails_helper"

RSpec.describe "admin/countries/_form", type: :view do
  before do
    assign(:country, Country.new)
  end

  it "renders" do
    render
  end
end
