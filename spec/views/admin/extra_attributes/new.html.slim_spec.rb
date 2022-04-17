require "rails_helper"

describe "admin/extra_attributes/new" do
  before do
    assign(:extra_attribute, ExtraAttribute.new)
  end

  it "renders" do
    render
  end
end
