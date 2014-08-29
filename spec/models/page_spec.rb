require 'rails_helper'

describe Page do
  it { should ensure_length_of(:description).is_at_most(200) }

  it 'allows a dot in the slug' do
    page = FactoryGirl.build(:page)
    page.slug = 'legacy.html'
    expect(page).to be_valid
  end

  it 'allows underscores in the slug' do
    page = FactoryGirl.build(:page)
    page.slug = 'legacy_page'
    expect(page).to be_valid
  end

  describe '#extra_json' do
    it 'handles nil values of extra' do
      expect { Page.new.extra_json }.not_to raise_error
    end
  end
end
