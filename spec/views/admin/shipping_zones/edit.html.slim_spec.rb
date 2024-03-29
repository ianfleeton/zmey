require "rails_helper"

RSpec.describe "admin/shipping_zones/edit", type: :view do
  let(:shipping_zone) { FactoryBot.create(:shipping_zone) }
  before do
    assign(:shipping_zone, shipping_zone)
  end

  context "without countries in this zone" do
    it "says there are no countries" do
      render
      expect(rendered).to have_content I18n.t("admin.shipping_zones.edit.no_countries")
    end
  end

  context "with countries in this zone" do
    let!(:country) { FactoryBot.create(:country, shipping_zone: shipping_zone) }

    it "links to edit the country" do
      render
      expect(rendered).to have_css "a[href='#{edit_admin_country_path(country)}']"
    end
  end

  context "with classes in this zone" do
    let!(:shipping_class) { FactoryBot.create(:shipping_class, shipping_zone: shipping_zone) }
    it "links to edit the class" do
      render
      expect(rendered).to have_css "a[href='#{edit_admin_shipping_class_path(shipping_class)}']"
    end
  end
end
