# frozen_string_literal: true

require "rails_helper"

module PDF
  RSpec.describe OrderConfirmationInfo do
    before do
      FactoryBot.create(:website)
      FactoryBot.create(
        :liquid_template, name: "pdfs.order_confirmation_info",
                          markup: "outer {{ order_confirmation_info }}"
      )
      FactoryBot.create(
        :liquid_template, name: "order_confirmation_info.html", markup: "inner"
      )
    end

    let(:oci) { OrderConfirmationInfo.new }

    describe "#generate" do
      it "works" do
        oci.generate
      end
    end

    describe "#html" do
      subject { oci.html }
      it { should include "outer inner" }
    end

    describe "#filename" do
      subject { oci.filename }
      it { should eq "tmp/OrderConfirmationInfo.pdf" }
    end
  end
end
