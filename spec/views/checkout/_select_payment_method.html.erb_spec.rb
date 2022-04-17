require "rails_helper"

RSpec.describe "checkout/_select_payment_method", type: :view do
  context "when WorldPay active" do
    let(:website) { FactoryBot.create(:website, worldpay_active: true, worldpay_installation_id: "1234", worldpay_payment_response_password: "secret") }
    let(:order) { FactoryBot.create(:order) }

    before do
      without_partial_double_verification do
        allow(view).to receive(:website).and_return(website)
      end
      assign(:order, order)
    end

    it "renders" do
      render
    end

    context "with skip_payment set" do
      before { website.skip_payment = true }

      it "renders" do
        render
      end
    end
  end

  context "when Cardsave active" do
    let(:website) { FactoryBot.create(:website, cardsave_active: true) }
    let(:order) { FactoryBot.create(:order) }

    before do
      without_partial_double_verification do
        allow(view).to receive(:website).and_return(website)
      end
      assign(:order, order)
    end

    it "renders" do
      render
    end
  end

  context "when website accepts payment on account" do
    let(:website) { FactoryBot.create(:website, accept_payment_on_account: true) }
    let(:order) { FactoryBot.create(:order) }

    before do
      without_partial_double_verification do
        allow(view).to receive(:website).and_return(website)
      end
      assign(:order, order)
    end

    it "has a form to place order on account" do
      render
      expect(rendered).to have_selector "form[action='#{on_account_payments_path}']"
      expect(rendered).to have_selector "input[type='submit'][value='#{t("checkout.select_payment_method.place_order_on_account")}']"
    end
  end
end
