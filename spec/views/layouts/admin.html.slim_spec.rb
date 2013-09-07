require 'spec_helper'

describe 'layouts/admin.html.slim' do
  let(:website) { Website.new(name: 'My Website') }

  before do
    assign(:w, website)
  end

  it 'renders' do
    render
  end
end
