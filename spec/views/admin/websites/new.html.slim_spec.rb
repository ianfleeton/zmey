require 'rails_helper'

describe '/admin/websites/new.html.slim' do
  before do
    assign(:website_subject, Website.new)
    allow(view).to receive(:website).and_return(Website.new)
  end

  context 'when manager' do
    before do
      allow(view).to receive(:admin?).and_return(false)
    end

    it 'has a field for theme' do
      render
      expect(rendered).to have_selector('input[id="website_theme"]')
    end
  end
end
