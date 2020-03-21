require "rails_helper"

RSpec.describe "orders/_invoice.html.slim", type: :view do
  let(:order) { FactoryBot.create(:order) }

  it "renders" do
    allow(view).to receive(:order).and_return(order)
    allow(view).to receive(:website).and_return FactoryBot.build(:website)

    render
  end
end
