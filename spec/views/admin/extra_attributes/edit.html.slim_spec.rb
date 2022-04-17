require "rails_helper"

describe "admin/extra_attributes/edit" do
  before do
    assign(:extra_attribute, ExtraAttribute.new)
  end

  it "renders" do
    render
  end
end
