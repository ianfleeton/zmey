require 'rails_helper'

RSpec.describe 'layouts/admin.html.slim', type: :view do
  let(:website) { FactoryGirl.create(:website) }

  before do
    allow(view).to receive(:website).and_return(website)
  end

  it 'has a link to sign out' do
    render
    expect(rendered).to have_selector "a[href='#{sessions_path}']"
  end
end
