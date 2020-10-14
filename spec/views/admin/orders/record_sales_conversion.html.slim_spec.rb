# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/orders/record_sales_conversion", type: :view do
  let(:order) { FactoryBot.create(:order) }

  before do
    conversion = instance_double(Orders::SalesConversion)
    allow(Orders::SalesConversion).to receive(:new).with(order).and_return(conversion)
    allow(conversion)
      .to receive(:should_record?)
      .and_return(should_record?)
    assign(:order, order)
    without_partial_double_verification do
      allow(view)
        .to receive(:website)
        .and_return(Website.new(google_analytics_code: "UA-1234"))
    end
  end

  context "when order should record sales conversion" do
    let(:should_record?) { true }
    it "calls #record_sales_conversion" do
      expect(view).to receive(:record_sales_conversion)
      render
    end
  end

  context "when order should not record sales conversion" do
    let(:should_record?) { false }
    it "does not call #record_sales_conversion" do
      expect(view).not_to receive(:record_sales_conversion)
      render
    end
  end
end
