require 'rails_helper'

describe Country do
  before do
    Country.create!(name: 'United Kingdom', iso_3166_1_alpha_2: 'GB')
  end

  it { should validate_uniqueness_of(:iso_3166_1_alpha_2) }
  it { should validate_uniqueness_of(:name) }

  describe '.populate!' do
    it 'should create a number of countries' do
      Country.populate!
      expect(Country.count).to eq 248
    end
  end

  describe '.shipping' do
    it 'returns only countries with a shipping zone assigned' do
      zone = FactoryGirl.create(:shipping_zone)
      c1 = FactoryGirl.create(:country, shipping_zone: zone)
      c2 = FactoryGirl.create(:country)
      expect(Country.shipping).to include(c1)
      expect(Country.shipping).not_to include(c2)
    end

    context 'when none with shipping zone' do
      it 'returns all countries' do
        c1 = FactoryGirl.create(:country)
        expect(Country.shipping).to include(c1)
      end
    end
  end
end
