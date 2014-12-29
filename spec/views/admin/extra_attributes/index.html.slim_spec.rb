require 'rails_helper'

describe 'admin/extra_attributes/index.html.slim' do
  let(:extra_attributes) { [] }

  before do
    assign(:extra_attributes, extra_attributes)
  end

  it 'links to the new attribute page' do
    render
    expect(rendered).to have_selector "a[href='#{new_admin_extra_attribute_path}']"
  end

  context 'with attributes' do
    let(:extra_attribute) { FactoryGirl.create(:extra_attribute) }
    let(:extra_attributes) { [extra_attribute] }

    it 'has a link to edit attribute' do
      render
      expect(rendered).to have_selector "a[href='#{edit_admin_extra_attribute_path(extra_attribute)}']"
    end

    it 'has a link to delete attribute' do
      render
      expect(rendered).to have_selector "a[href='#{admin_extra_attribute_path(extra_attribute)}'][data-method='delete']"
    end
  end
end
