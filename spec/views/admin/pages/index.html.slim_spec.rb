require "rails_helper"

RSpec.describe "admin/pages/index", type: :view do
  let(:parent) { FactoryBot.create(:page) }

  before do
    assign(:pages, [])
    assign(:parent, parent)
  end

  it "has a link to edit the page" do
    render
    expect(rendered).to have_selector "a[href='#{edit_admin_page_path(parent)}']"
  end
end
