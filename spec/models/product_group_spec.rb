require 'rails_helper'

describe ProductGroup do
  describe '#to_s' do
    it 'returns name' do
      expect(ProductGroup.new(name: 'BOGOF').to_s).to eq 'BOGOF'
    end
  end
end
