require "rails_helper"

RSpec.describe "checkout/_yorkshire_payments.html.erb", type: :view do
  let(:website) { FactoryBot.build(:website) }
  let(:order) { FactoryBot.build(:order) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
    end
    assign(:order, order)
    render
  end

  context "rendered" do
    subject { rendered }
    it { should have_selector "form[action='https://gateway.yorkshirepayments.com/paymentform/'][method='post']" }
  end
end
