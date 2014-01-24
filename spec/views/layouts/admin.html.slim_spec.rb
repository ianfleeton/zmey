require 'spec_helper'

describe 'layouts/admin.html.slim' do
  let(:website) { FactoryGirl.create(:website) }

  before do
    view.stub(:website).and_return(website)
  end

  it 'has a link to sign out' do
    render
    expect(rendered).to have_selector "a[href='#{sessions_path}']"
  end
end
