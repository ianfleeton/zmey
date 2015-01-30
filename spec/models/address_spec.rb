require 'rails_helper'

describe Address do
  describe 'before validation' do
    context 'with label present' do
      it 'leaves the label untouched' do
        a = Address.new(label: 'Home')
        a.save
        expect(a.label).to eq 'Home'
      end
    end

    context 'with label blank' do
      it 'generates a label for the address based on name and postcode' do
        a = Address.new(full_name: 'Ian Fleeton', postcode: 'L0N D0N')
        a.save
        expect(a.label).to eq 'Ian Fleeton - L0N D0N'
      end
    end
  end

  describe '#shipping_zone' do
    it 'is delegated to country' do
      zone = FactoryGirl.create(:shipping_zone)
      country = FactoryGirl.create(:country, shipping_zone: zone)
      address = FactoryGirl.create(:address, country: country)
      expect(address.shipping_zone).to eq zone
    end

    it 'returns nil if no country' do
      expect(Address.new.shipping_zone).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns label attribute' do
      expect(Address.new(label: 'x').to_s).to eq 'x'
    end
  end
end
