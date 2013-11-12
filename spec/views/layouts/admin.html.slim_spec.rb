require 'spec_helper'

describe 'layouts/admin.html.slim' do
  let(:website) { FactoryGirl.create(:website) }

  before do
    assign(:w, website)
  end

  it 'renders' do
    render
  end
end
