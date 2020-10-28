require "rails_helper"

RSpec.describe "checkout/confirm.html.erb", type: :view do
  let(:logged_in?) { true }
  let(:billing_address) { Address.new }
  let(:delivery_address) { Address.new }
  let(:basket) { Basket.new }
  let(:discount_lines) { [] }
  let(:requires_delivery_address?) { true }
  let(:order) do
    FactoryBot.build(
      :order, requires_delivery_address: requires_delivery_address?
    )
  end
  let(:shipping_amount) { 0 }
  let(:shipping_tax_amount) { 0 }
  let(:delivery_date) { nil }
  let(:website) { FactoryBot.create(:website) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:logged_in?).and_return logged_in?
      allow(view).to receive(:current_user).and_return(User.new)
      allow(view).to receive(:basket).and_return basket
      allow(view).to receive(:running_in_production?).and_return(false)
      allow(view).to receive(:website).and_return website

      allow(view).to receive(:delivery_date).and_return(delivery_date)
    end

    assign(:billing_address, billing_address)
    assign(:delivery_address, delivery_address)
    assign(:shipping_amount, shipping_amount)
    assign(:shipping_tax_amount, shipping_tax_amount)
    assign(:basket, basket)
    assign(:discount_lines, discount_lines)
    assign(:order, order)
  end

  context "without delivery_date set by customer" do
    it "displays estimated delivery date" do
      pending
      expect(rendered).to have_content "Thursday 12th February, 2015"
    end
  end

  context "with delivery_date set by customer" do
    let(:delivery_date) { Date.new(2017, 7, 5) }
    it "displays the delivery date" do
      render
      expect(rendered).to have_content "Wednesday 5th July, 2017"
    end
  end

  it "displays delivery instructions" do
    basket.delivery_instructions = "Leave with neighbour"
    render
    expect(rendered).to have_content "Leave with neighbour"
  end

  context "when order does not require delivery address" do
    let(:requires_delivery_address?) { false }
    let(:delivery_address) { nil }
    it "renders info about collection" do
      render
      expect(rendered).to have_content "Collecting your order"
    end
  end
end
