require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { should belong_to(:order).optional }
  end

  describe "after_save" do
    let(:order) { FactoryBot.create(:order) }
    let(:payment) { FactoryBot.build(:payment, accepted: accepted, order: order) }

    context "when accepted" do
      let(:accepted) { true }
      it "notifies its order" do
        expect(order).to receive(:payment_accepted).with(payment)
        payment.save
      end
    end

    context "when not accepted" do
      let(:accepted) { false }
      it "does not notify its order" do
        expect(order).not_to receive(:payment_accepted)
        payment.save
      end
    end
  end

  describe "#paypal_ipn?" do
    subject { Payment.new(service_provider: provider).paypal_ipn? }
    context "when provider is PayPal IPN" do
      let(:provider) { "PayPal (IPN)" }
      it { should be_truthy }
    end
    context "when provider is not PayPal IPN" do
      let(:provider) { "PayPal Express Checkout" }
      it { should be_falsey }
    end
  end
end
