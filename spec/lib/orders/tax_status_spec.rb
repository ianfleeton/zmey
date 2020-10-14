# frozen_string_literal: true

require "rails_helper"

module Orders
  RSpec.describe TaxStatus do
    describe "#zero_rated?" do
      let(:billing_company) { nil }
      let(:billing_country) { Country.new }
      let(:delivery_country) { Country.new }
      let(:vat_number) { nil }
      let(:order) do
        FactoryBot.build(
          :order,
          billing_company: billing_company,
          billing_country: billing_country,
          delivery_country: delivery_country,
          vat_number: vat_number
        )
      end
      let(:status) { TaxStatus.new(order) }

      subject { status.zero_rated? }

      context "when billing country is unset" do
        let(:billing_country) { nil }
        it { should be_falsey }
      end

      context "when billing country is the UK" do
        before do
          allow(billing_country).to receive(:uk?).and_return(true)
        end
        it { should be_falsey }
      end

      context "when billing country is in the EU" do
        before do
          allow(billing_country).to receive(:in_eu?).and_return(true)
        end

        context "when delivery country is the same" do
          let(:delivery_country) { billing_country }

          context "when VAT number is present" do
            let(:vat_number) { "GB123" }
            context "when billing company present" do
              let(:billing_company) { "ACME Widgets Ltd" }
              it { should be_truthy }
            end
            context "when billing company absent" do
              let(:billing_company) { nil }
              it { should be_falsey }
            end
          end

          context "when VAT number is absent" do
            let(:vat_number) { nil }
            context "when billing company present" do
              let(:billing_company) { "ACME Widgets Ltd" }
              it { should be_falsey }
            end
            context "when billing company absent" do
              let(:billing_company) { nil }
              it { should be_falsey }
            end
          end
        end

        context "when delivery country is different but VAT number and " \
        "company present" do
          let(:delivery_country) { Country.new }
          let(:vat_number) { "GB123" }
          it { should be_falsey }
        end
      end

      context "when billing country is not UK or in EU" do
        before do
          allow(billing_country).to receive(:in_eu?).and_return(false)
          allow(billing_country).to receive(:uk?).and_return(false)
        end

        context "when delivery country is the same" do
          let(:delivery_country) { billing_country }
          it { should be_truthy }
        end

        context "when delivery country is different" do
          it { should be_falsey }
        end
      end
    end
  end
end
