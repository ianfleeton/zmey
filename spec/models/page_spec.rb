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

  it 'nilifies blanks for extra' do
    page = FactoryGirl.build(:page, extra: '')
    page.save
    expect(page.extra).to be_nil
  end

  describe '#extra_json' do
    it 'handles nil values of extra' do
      expect { Page.new.extra_json }.not_to raise_error
    end
  end

  describe '#update_extra' do
    let(:page) { Page.new(extra: '{"subheading": "before", "exists": "already"}') }
    let(:hash) {{
      'subheading' => 'after',
      'bad' => 'ignored',
      'new' => 'inserted'
    }}

    before do
      ExtraAttribute.create!(attribute_name: 'subheading', class_name: 'Page')
      ExtraAttribute.create!(attribute_name: 'exists', class_name: 'Page')
      ExtraAttribute.create!(attribute_name: 'new', class_name: 'Page')
    end

    it 'updates extra' do
      before = page.extra
      page.update_extra(hash)
      expect(page.extra).not_to eq before
    end

    it 'returns true when extra is changed' do
      expect(page.update_extra(hash)).to eq true
    end

    it 'returns false when extra is not changed' do
      expect(Page.new.update_extra({})).to eq false
    end

    it 'updates existing entries' do
      page.update_extra(hash)
      expect(page.extra_json['subheading']).to eq 'after'
    end

    it 'adds new entries' do
      page.update_extra(hash)
      expect(page.extra_json['new']).to eq 'inserted'
    end

    it 'ignores entries not in ExtraAttribute' do
      page.update_extra(hash)
      expect(page.extra_json['bad']).to be_nil
    end

    it 'preserves values' do
      page.update_extra(hash)
      expect(page.extra_json['exists']).to eq 'already'
    end
  end
end
