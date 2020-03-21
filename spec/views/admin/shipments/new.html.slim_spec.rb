require "rails_helper"

RSpec.describe "admin/shipments/new.html.slim" do
  let(:shipment) { Shipment.new }

  before do
    assign(:shipment, shipment)
  end

  it "renders a form for the @shipment" do
    render
    expect(rendered).to have_selector "form[action='#{admin_shipments_path}'][method='post']"
  end

  context "form fields" do
    before { render }
    subject { rendered }

    [
      'textarea[name="shipment[comment]"]',
      'input[name="shipment[courier_name]"][type="text"]',
      'input[name="shipment[number_of_parcels]"][type="number"]',
      'input[name="shipment[partial]"][type="checkbox"]',
      'input[name="shipment[picked_by]"][type="text"]',
      'input[name="shipment[total_weight]"][type="text"]',
      'input[name="shipment[tracking_number]"][type="text"]',
      'input[name="shipment[tracking_url]"][type="url"]'
    ].each { |sel| it { should have_selector sel } }
    it { should have_selector 'input[name="shipment[order_id]"][type="hidden"]', visible: false }
    it { should have_selector 'input[name="shipment[shipped_at]"][type="hidden"]', visible: false }
  end
end
