require 'rails_helper'

RSpec.describe 'application/_navigation.html.slim', type: :view do
  before do
    allow(Page).to receive(:navs).and_return navs
    allow(view).to receive(:logged_in?).and_return false
    allow(view).to receive(:website).and_return Website.new
  end

  context 'with a primary nav' do
    let(:navs) do
      n = Navigation.new
      n.id_attribute = 'primary_nav'
      n.pages = []
      [n]
    end

    it 'has a link to checkout' do
      render
      expect(rendered).to have_selector "a[href='#{checkout_path}']"
    end
  end
end
