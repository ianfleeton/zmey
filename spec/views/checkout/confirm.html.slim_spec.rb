require "rails_helper"

RSpec.describe "checkout/confirm.html.slim", type: :view do
  let(:basket) { Basket.new }
  let(:billing_address) { FactoryBot.create(:address) }
  let(:delivery_address) { FactoryBot.create(:address) }
  let(:website) { FactoryBot.create(:website) }
  let(:name) { SecureRandom.hex }
  let(:email) { SecureRandom.hex }
  let(:phone) { SecureRandom.hex }

  before do
    assign(:billing_address, billing_address)
    assign(:delivery_address, delivery_address)
    assign(:discount_lines, [])
    without_partial_double_verification do
      allow(view).to receive(:basket).and_return basket
      allow(view).to receive(:website).and_return(website)
      allow(view).to receive(:logged_in?).and_return(false)
    end
    session[:name] = name
    session[:email] = email
    session[:phone] = phone
    render
  end

  it "shows customer details" do
    expect(rendered).to have_content I18n.t("checkout.confirm.your_details")
    expect(rendered).to have_content name
    expect(rendered).to have_content email
    expect(rendered).to have_content phone
  end

  it "has a link to edit details" do
    expect(rendered).to have_selector "a[href='#{checkout_details_path}']", text: I18n.t("checkout.confirm.edit_details")
  end

  it "shows billing address" do
    expect(rendered).to have_content I18n.t("checkout.confirm.billing_address")
  end

  it "links to edit billing address" do
    expect(rendered).to have_selector "a[href='#{billing_details_path}']", text: I18n.t("checkout.confirm.edit_address")
  end

  it "shows delivery address" do
    expect(rendered).to have_content I18n.t("checkout.confirm.delivery_address")
  end

  it "links to edit delivery address" do
    expect(rendered).to have_selector "a[href='#{delivery_details_path}']", text: I18n.t("checkout.confirm.edit_address")
  end
end
