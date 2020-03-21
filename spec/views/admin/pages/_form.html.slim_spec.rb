require "rails_helper"

describe "admin/pages/_form.html.slim" do
  before do
    allow(view).to receive(:submit_label).and_return("Save")
    allow(view).to receive(:website).and_return(Website.new)
    assign(:page, FactoryBot.create(:page))
  end

  it_behaves_like "an extra attributes form", "Page"
end
