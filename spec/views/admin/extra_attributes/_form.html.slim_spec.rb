require "rails_helper"

describe "admin/extra_attributes/_form.html.slim" do
  before do
    assign(:extra_attribute, ExtraAttribute.new)
  end

  it "has fields for class_name and attribute" do
    render
    expect(rendered).to have_selector 'input[name="extra_attribute[class_name]"]'
    expect(rendered).to have_selector 'input[name="extra_attribute[attribute_name]"]'
  end

  it "has a save button" do
    render
    expect(rendered).to have_selector 'input[type="submit"]'
  end
end
