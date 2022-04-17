require "rails_helper"

RSpec.describe "checkout/details" do
  it "has a form to save details" do
    render
    expect(rendered).to have_selector "form[action='#{save_details_path}']"
  end

  it "has a heading" do
    render
    expect(rendered).to have_selector "h1", text: I18n.t("checkout.details.heading")
  end

  it "has prefilled, required fields for name, phone and email" do
    session[:name] = SecureRandom.hex
    session[:email] = SecureRandom.hex
    session[:phone] = SecureRandom.hex
    render
    expect(rendered).to have_selector "input[name='name'][value='#{session[:name]}'][required]"
    expect(rendered).to have_selector "input[name='email'][type='email'][value='#{session[:email]}'][required]"
    expect(rendered).to have_selector "input[name='phone'][type='tel'][value='#{session[:phone]}'][required]"
  end

  it "has a submit button" do
    render
    expect(rendered).to have_selector "input[type='submit'][value='#{I18n.t("checkout.details.continue")}']"
  end
end
