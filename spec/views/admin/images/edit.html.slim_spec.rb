require 'rails_helper'

describe 'admin/images/edit.html.slim' do
  it 'renders' do
    assign(:image, FactoryBot.create(:image))
    render
  end
end
