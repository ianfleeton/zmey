require 'rails_helper'

describe LiquidTemplate do
  describe '#to_s' do
    it 'returns its name' do
      expect(LiquidTemplate.new(name: 'Footer').to_s).to eq 'Footer'
    end
  end
end
