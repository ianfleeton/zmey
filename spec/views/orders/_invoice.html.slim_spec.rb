require "rails_helper"

RSpec.describe "orders/_invoice.html.slim", type: :view do
  let(:order) { FactoryBot.create(:order) }

  it "renders" do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return FactoryBot.build(:website)
    end

    render partial: "orders/invoice", locals: {order: order}
  end
end
