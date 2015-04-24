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
    before { setup_address_with_shipping_classes }

    it 'is delegated to country' do
      expect(@address.shipping_zone).to eq @shipping_zone
    end

    it 'returns nil if no country' do
      expect(Address.new.shipping_zone).to be_nil
    end
  end

  describe '#shipping_classes' do
    context 'with shipping zone' do
      before { setup_address_with_shipping_classes }

      it 'returns the shipping zone\'s classes' do
        expect(@address.shipping_classes).to include(@shipping_class)
      end
    end

    context 'without shipping zone' do
      it 'returns an empty array' do
        expect(Address.new.shipping_classes).to eq []
      end
    end
  end

  def setup_address_with_shipping_classes
    @shipping_zone = FactoryGirl.create(:shipping_zone)
    @shipping_class = FactoryGirl.create(:shipping_class, shipping_zone: @shipping_zone)
    @country = FactoryGirl.create(:country, shipping_zone: @shipping_zone)
    @address = FactoryGirl.create(:address, country: @country)
  end

  describe '#to_s' do
    it 'returns label attribute' do
      expect(Address.new(label: 'x').to_s).to eq 'x'
    end
  end
end
