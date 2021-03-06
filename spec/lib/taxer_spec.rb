require "rails_helper"

RSpec.describe Taxer do
  before { allow(Product).to receive(:vat_rate).and_return(0.2) }

  describe "#inc_vat" do
    subject { Taxer.new(price, tax_type).inc_vat }
    let(:price) { 10 }

    context "tax_type is Product::EX_VAT" do
      let(:tax_type) { Product::EX_VAT }
      it { should eq 12 }
    end

    context "tax_type is Product::INC_VAT" do
      let(:tax_type) { Product::INC_VAT }
      it { should eq 10 }
    end

    context "tax_type is Product::NO_TAX" do
      let(:tax_type) { Product::NO_TAX }
      it { should eq 10 }
    end

    context "price is nil" do
      let(:tax_type) { Product::EX_VAT }
      let(:price) { nil }
      it { should eq nil }
    end
  end

  describe "#ex_vat" do
    subject { Taxer.new(price, tax_type).ex_vat }
    let(:price) { 12 }

    context "tax_type is Product::EX_VAT" do
      let(:tax_type) { Product::EX_VAT }
      it { should eq 12 }
    end

    context "tax_type is Product::INC_VAT" do
      let(:tax_type) { Product::INC_VAT }
      it { should eq 10 }
    end

    context "tax_type is Product::NO_TAX" do
      let(:tax_type) { Product::NO_TAX }
      it { should eq 12 }
    end

    context "price is nil" do
      let(:tax_type) { Product::INC_VAT }
      let(:price) { nil }
      it { should eq nil }
    end
  end
end
