require "rails_helper"

module Orders
  RSpec.describe SalesConversion do
    describe "#should_record?" do
      let(:order) do
        Order.new(
          sales_conversion_recorded_at: sales_conversion_recorded_at,
          credit_account: credit_account?
        )
      end
      let(:payment_received?) { true }
      let(:credit_account?) { false }
      let(:sales_conversion_recorded_at) { nil }

      subject { SalesConversion.new(order).should_record? }

      before do
        allow(order).to receive(:payment_received?).and_return(payment_received?)
      end

      context "when conversion already recorded" do
        let(:sales_conversion_recorded_at) { Date.current }
        it { should eq false }
      end

      context "when payment not received" do
        let(:payment_received?) { false }
        it { should eq false }
      end

      context "when payment not received, but a credit account" do
        let(:payment_received?) { false }
        let(:credit_account?) { true }
        it { should eq true }
      end
    end

    describe "#record!" do
      let(:order) { FactoryBot.build(:order) }

      it "updates sales_conversion_recorded_at" do
        SalesConversion.new(order).record!
        expect(order.sales_conversion_recorded_at).to be
      end

      it "saves the order" do
        SalesConversion.new(order).record!
        expect(order.persisted?).to eq true
      end
    end
  end
end
