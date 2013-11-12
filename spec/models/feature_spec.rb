require 'spec_helper'

describe Feature do
  describe '#to_s' do
    it 'returns its name' do
      expect(Feature.new(name: 'Colour').to_s).to eq 'Colour'
    end
  end
end
