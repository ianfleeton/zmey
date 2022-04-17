require "rails_helper"

describe "admin/api_keys/new" do
  before { assign(:api_key, ApiKey.new) }

  it "renders" do
    render
  end
end
