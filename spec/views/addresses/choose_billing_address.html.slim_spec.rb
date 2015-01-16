require 'rails_helper'

RSpec.describe 'addresses/choose_billing_address.html.slim', type: :view do
  before do
    assign(:addresses, [])
  end

  it 'renders the choose_address partial' do
    render
    expect(view).to have_rendered partial: 'choose_address', locals: { source: 'billing' }
  end
end
