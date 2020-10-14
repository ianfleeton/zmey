require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "associations" do
    it { should belong_to(:order).optional }
  end

  describe "before_save" do
    let!(:order) { FactoryBot.create(:order) }
    let(:payment) do
      Payment.new(
        order: order,
        accepted: true,
        transaction_id: "T1",
        service_provider: service_provider,
        amount: "1"
      )
    end

    context "when a PayPal (IPN)" do
      let(:service_provider) { "PayPal (IPN)" }
      it "sets its accepted to false if another PayPal payment with same " \
      "transaction_id exists" do
        FactoryBot.create(
          :payment,
          service_provider: "PayPal Express",
          order: order,
          transaction_id: "T1"
        )
        payment.save
        expect(payment.accepted).to eq false
      end

      it "leaves accepted alone if another PayPal payment with different " \
      "transaction_id exists" do
        FactoryBot.create(
          :payment,
          service_provider: "PayPal Express",
          order: order,
          transaction_id: "T2"
        )
        payment.save
        expect(payment.accepted).to eq true
      end

      it "leaves accepted alone if a different payment type with same " \
      "transaction_id exists" do
        FactoryBot.create(
          :payment,
          service_provider:
          "Cheque",
          order: order,
          transaction_id: "T1"
        )
        payment.save
        expect(payment.accepted).to eq true
      end
    end

    context "when another PayPal method" do
      let(:service_provider) { "PayPal Express" }

      it "sets existing PayPal (IPN) payment with same transaction_id " \
      "accepted to false" do
        ipn = FactoryBot.create(
          :payment,
          service_provider: "PayPal (IPN)",
          order: order,
          transaction_id: "T1",
          accepted: true
        )
        payment.save
        expect(ipn.reload.accepted).to eq false
      end

      it "leaves other PayPal (IPN) payment accepted alone if other payment " \
      "has different transaction_id" do
        ipn = FactoryBot.create(
          :payment,
          service_provider: "PayPal (IPN)",
          order: order,
          transaction_id: "T2",
          accepted: true
        )
        payment.save
        expect(ipn.reload.accepted).to eq true
      end

      it "leaves accepted alone if a different payment type with same " \
      "transaction_id exists" do
        cheque = FactoryBot.create(
          :payment,
          service_provider: "Cheque",
          order: order,
          transaction_id: "T1",
          accepted: true
        )
        payment.save
        expect(cheque.accepted).to eq true
      end
    end

    context "when another method entirely" do
      let(:service_provider) { "Cheque" }
      it "leaves other PayPal (IPN) payment accepted alone if other payment " \
      "has same transaction_id" do
        ipn = FactoryBot.create(
          :payment,
          service_provider: "PayPal (IPN)",
          order: order,
          transaction_id: "T1",
          accepted: true
        )
        payment.save
        expect(ipn.reload.accepted).to eq true
      end
    end
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

  describe "#auth_code=" do
    let(:payment) { Payment.new(transaction_id: "orig") }

    before do
      payment.auth_code = auth_code
    end

    subject { payment.transaction_id }

    context "when param blank" do
      let(:auth_code) { "" }
      it { should eq "orig" }
    end

    context "when param present" do
      let(:auth_code) { "123456" }
      it { should eq "Auth code 123456" }
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
