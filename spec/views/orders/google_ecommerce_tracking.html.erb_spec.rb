require "rails_helper"

RSpec.describe "orders/_google_ecommerce_tracking.html.erb", type: :view do
  let(:order) { FactoryBot.create(:order) }

  before do
    FactoryBot.create(:order_line, order: order)
    allow(view).to receive(:website).and_return(FactoryBot.build(:website))
  end

  it "renders" do
    render partial: "google_ecommerce_tracking", locals: {order: order}
  end
end
