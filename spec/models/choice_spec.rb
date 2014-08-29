require 'rails_helper'

describe Choice do
  describe '#to_s' do
    it 'returns its name' do
      expect(Choice.new(name: 'Blue').to_s).to eq 'Blue'
    end
  end
end
