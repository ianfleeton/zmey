require 'rails_helper'

RSpec.describe 'checkout/_yorkshire_payments.html.slim', type: :view do
  let(:website) { FactoryGirl.build(:website) }
  let(:order) { FactoryGirl.build(:order) }

  before do
    allow(view).to receive(:website).and_return(website)
    assign(:order, order)
    render
  end

  context 'rendered' do
    subject { rendered }
    it { should have_selector "form[action='https://gateway.yorkshirepayments.com/paymentform/'][method='post']" }
  end

  context 'view' do
    subject { view }
    it { should render_template 'checkout/_yorkshire_payments_hidden_fields'}
  end
end
