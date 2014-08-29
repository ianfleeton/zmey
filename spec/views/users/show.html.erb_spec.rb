require 'rails_helper'

describe 'users/show.html.erb' do
  before do
    assign(:user, double(User, name: 'A. Customer', email: 'customer@example.org', managed_website: nil))
  end

  it 'renders' do
    render
  end
end
