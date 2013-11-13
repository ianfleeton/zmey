require 'spec_helper'

describe Component do
  describe '#to_s' do
    it 'returns its name' do
      expect(Component.new(name: 'Size/Colour').to_s).to eq 'Size/Colour'
    end
  end
end
