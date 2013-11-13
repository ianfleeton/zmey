require 'spec_helper'

describe 'layouts/admin.html.slim' do
  let(:website) { FactoryGirl.create(:website) }

  before do
    view.stub(:website).and_return(website)
  end

  it 'renders' do
    render
  end
end
