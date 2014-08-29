require 'rails_helper'

describe ShippingClass do
  describe '#to_s' do
    it 'returns its name' do
      expect(ShippingClass.new(name: 'First Class').to_s).to eq 'First Class'
    end
  end
end
