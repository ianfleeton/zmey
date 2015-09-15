require 'rails_helper'

RSpec.describe 'admin/shipping_zones/edit.html.slim', type: :view do
  let(:shipping_zone) { FactoryGirl.create(:shipping_zone) }
  before do
    assign(:shipping_zone, shipping_zone)
  end

  context 'without countries in this zone' do
    it 'says there are no countries' do
      render
      expect(rendered).to have_content I18n.t('admin.shipping_zones.edit.no_countries')
    end
  end

  context 'with countries in this zone' do
    let!(:country) { FactoryGirl.create(:country, shipping_zone: shipping_zone) }

    it 'links to edit the country' do
      render
      expect(rendered).to have_css "a[href='#{edit_admin_country_path(country)}']"
    end
  end
end
