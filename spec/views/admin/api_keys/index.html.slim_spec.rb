require 'rails_helper'

describe 'admin/api_keys/index.html.slim' do
  let(:api_keys) { [] }

  before do
    assign(:api_keys, api_keys)
    render
  end

  it 'has a link to create a new API key' do
    expect(rendered).to have_selector "a[href='#{new_admin_api_key_path}']"
  end

  context 'when @api_keys is empty' do
    it 'tells the user they have no keys yet' do
      expect(rendered).to have_content t('admin.api_keys.index.no_keys')
    end
  end

  context 'with some @api_keys' do
    let(:api_key)  { FactoryGirl.create(:api_key) }
    let(:api_keys) { [api_key] }

    it 'displays the API key and its name' do
      expect(rendered).to have_content (api_key.name)
      expect(rendered).to have_content (api_key.key)
    end
  end
end
