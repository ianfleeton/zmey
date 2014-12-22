require 'rails_helper'

describe 'admin/extra_attributes/index.html.slim' do
  it 'links to the new attribute page' do
    render
    expect(rendered).to have_selector "a[href='#{new_admin_extra_attribute_path}']"
  end
end
