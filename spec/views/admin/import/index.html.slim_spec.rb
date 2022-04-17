require "rails_helper"

RSpec.describe "admin/import/index", type: :view do
  it "has options for importable classes" do
    render
    ["Product", "ProductGroup"].each do |class_name|
      expect(rendered).to have_css("option", text: class_name)
    end
  end
end
