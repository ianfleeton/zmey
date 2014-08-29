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

  describe '#to_s' do
    it 'returns label attribute' do
      expect(Address.new(label: 'x').to_s).to eq 'x'
    end
  end
end
