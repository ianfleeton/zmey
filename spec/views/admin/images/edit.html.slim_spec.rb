require 'rails_helper'

describe 'admin/images/edit.html.slim' do
  it 'renders' do
    assign(:image, FactoryGirl.create(:image))
    render
  end
end
