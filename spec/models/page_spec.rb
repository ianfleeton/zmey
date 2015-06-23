require 'rails_helper'
require_relative 'shared_examples/extra_attributes_shared.rb'

describe Page do
  it { should validate_length_of(:description).is_at_most(200) }

  context 'uniqueness' do
    before  { FactoryGirl.create(:page) }
    it { should validate_uniqueness_of(:slug) }
    it { should validate_uniqueness_of(:title) }
  end

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

  it 'nilifies blanks for extra' do
    page = FactoryGirl.build(:page, extra: '')
    page.save
    expect(page.extra).to be_nil
  end

  it 'prevents parent referencing self' do
    page = FactoryGirl.create(:page)
    page.parent = page
    page.save
    expect(page.errors[:parent_id]).to include 'cannot be self'
  end

  it 'prevents parent from referencing a child' do
    page = FactoryGirl.create(:page)
    child = FactoryGirl.create(:page)
    page.children << child
    page.parent = child
    page.save
    expect(page.errors[:parent_id]).to include 'cannot be a child'
  end

  describe '#url' do
    it 'returns a full URL using the first website setting URL' do
      website = FactoryGirl.create(:website)
      page = FactoryGirl.build(:page, slug: 'slug')
      expect(page.url).to include('slug')
    end
  end

  it_behaves_like 'an object with extra attributes'
end
