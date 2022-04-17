require "rails_helper"

RSpec.describe "checkout/billing", type: :view do
  HIDDEN_PARAMS = {full_name: "fn"}.freeze
  let(:address) { Address.new(HIDDEN_PARAMS) }

  let(:shipping_class_name) { "Mainland UK" }
  let(:shipping_class) { ShippingClass.new(name: shipping_class_name) }

  let(:billing_address_id) { nil }
  let(:delivery_address_id) { nil }

  before do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(Website.new)
    end
    assign(:address, address)
    assign(:shipping_class, shipping_class)
    session[:billing_address_id] = billing_address_id
    session[:delivery_address_id] = delivery_address_id
    render
  end

  it "has a form to save details" do
    expect(rendered).to have_selector(
      "form[action='#{save_billing_details_path}'][method='post']"
    )
  end

  %w[
    address_line_1 address_line_2 town_city county postcode phone_number mobile_number
  ].each do |component|
    it "has a field for #{component}" do
      expect(rendered).to have_selector "input[name='address[#{component}]']"
    end
  end

  HIDDEN_PARAMS.each do |k, v|
    it "has a hidden field for #{k} with value #{v}" do
      expect(rendered).to have_selector(
        "input[type='hidden'][name='address[#{k}]'][value='#{v}']",
        visible: false
      )
    end
  end

  it "has a select box for email" do
    expect(rendered).to have_selector "input[name='address[email_address]']"
  end

  it "has a select box for country" do
    expect(rendered).to have_selector "select[name='address[country_id]']"
  end

  it "has a submit button" do
    expect(rendered).to have_selector "input[type='submit']"
  end

  context "when shipping class is Collection" do
    let(:shipping_class_name) { "Collection" }
    it "has no information about collection" do
      expect(rendered).not_to have_css ".collection-info"
    end
  end

  context "when shipping class is not Collection" do
    it "has information about collection" do
      expect(rendered).to have_css ".collection-info"
    end
  end

  context "when delivery and billing addresses are already chosen and the " \
  "same" do
    let(:billing_address_id) { 1 }
    let(:delivery_address_id) { 1 }

    it "should check the checkbox to deliver here" do
      expect(rendered).to have_selector "input#deliver_here[checked]"
    end
  end

  context "when delivery and billing addresses are already chosen but " \
  "different" do
    let(:billing_address_id) { 1 }
    let(:delivery_address_id) { 2 }

    it "should not check the checkbox to deliver here" do
      expect(rendered).to have_selector "input#deliver_here"
      expect(rendered).not_to have_selector "input#deliver_here[checked]"
    end
  end

  context "when delivery and billing addresses are both nil" do
    it "should not check the checkbox to deliver here" do
      expect(rendered).to have_selector "input#deliver_here"
      expect(rendered).not_to have_selector "input#deliver_here[checked]"
    end
  end
end
