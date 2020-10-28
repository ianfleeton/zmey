# frozen_string_literal: true

require "rails_helper"

RSpec.describe "orders/invoice.html.erb", type: :view do
  let(:customer_note) { nil }
  let(:po_number) { nil }
  let!(:status) { Enums::PaymentStatus::WAITING_FOR_PAYMENT }
  let(:order) do
    FactoryBot.create(
      :order,
      customer_note: customer_note, po_number: po_number,
      status: status, user: user
    )
  end
  let!(:payment) { nil }
  let!(:quote_template) { nil }
  let!(:user) { nil }

  before do
    assign(:order, order)
    without_partial_double_verification do
      allow(view).to receive(:website).and_return FactoryBot.build(:website)
    end
    render
  end

  subject { rendered }

  describe "quote heading" do
    let(:quote_template) do
      FactoryBot.create(
        :liquid_template, name: "invoice.quote_heading", markup: "quote heading"
      )
    end

    context "when order is a quote" do
      let(:status) { Enums::PaymentStatus::QUOTE }
      it { should have_content "quote heading" }
    end

    context "when order is not a quote" do
      it { should_not have_content "quote heading" }
    end
  end

  context "with blank customer_note" do
    it { should have_content "None" }
  end

  context "with customer_note set" do
    let(:customer_note) { "Some instructions" }
    it { should have_content customer_note }
  end

  context "with blank PO number" do
    it { should_not have_content "PO number" }
  end

  context "with PO number set" do
    let(:po_number) { "PO1234" }
    it { should have_content "PO number" }
    it { should have_content "PO1234" }
  end

  context "without payments" do
    it { should_not have_content "Payment method" }
  end

  context "with payments" do
    let(:payment) do
      FactoryBot.create(:payment, order: order, service_provider: "Stripe")
    end
    it { should have_content "Payment method" }
    it { should have_content "Stripe" }
  end

  context "when document is a pro-forma" do
    let(:status) { Enums::PaymentStatus::PRO_FORMA }

    it "displays the bank account number" do
      expect(rendered).to have_content "ACCOUNTNUMBER"
    end

    it "displays the pro-forma number as the payment reference" do
      expect(rendered)
        .to have_css ".payment-reference", text: order.order_number
    end
  end
end
