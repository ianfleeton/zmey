require 'rails_helper'

describe 'layouts/admin.html.slim' do
  let(:website) { FactoryGirl.create(:website) }

  before do
    allow(view).to receive(:website).and_return(website)
  end

  it 'has a link to sign out' do
    render
    expect(rendered).to have_selector "a[href='#{sessions_path}']"
  end

  it 'has a link to forums' do
    render
    expect(rendered).to have_slector "a[href='#{forums_path}]"
  end
end
