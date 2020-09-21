require "rails_helper"

RSpec.describe "layouts/admin.html.slim", type: :view do
  let(:website) { FactoryBot.create(:website) }

  before do
    without_partial_double_verification do
      allow(view).to receive(:website).and_return(website)
    end
  end

  it "has a link to sign out" do
    render
    expect(rendered).to have_selector "a[href='#{sessions_path}']"
  end
end
