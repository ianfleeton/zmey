# frozen_string_literal: true

require "rails_helper"

RSpec.describe "orders/_google_sales_conversion.html.erb", type: :view do
  let(:order) { FactoryBot.create(:order) }

  before do
    FactoryBot.create(:order_line, order: order)
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(FactoryBot.build(:website))
    end
  end

  it "renders" do
    render partial: "google_sales_conversion", locals: {order: order}
  end
end
