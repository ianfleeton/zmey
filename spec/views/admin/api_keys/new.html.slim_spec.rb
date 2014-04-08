require 'spec_helper'

describe 'admin/api_keys/new.html.slim' do
  before { assign(:api_key, ApiKey.new) }

  it 'renders' do
    render
  end
end
