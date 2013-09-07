require 'spec_helper'

describe 'users/show.html.erb' do
  before do
    assign(:user, stub_model(User))
    assign(:w, stub_model(Website))
  end

  it 'renders' do
    render
  end
end
