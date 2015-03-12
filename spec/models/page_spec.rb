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

  it_behaves_like 'an object with extra attributes'
end
