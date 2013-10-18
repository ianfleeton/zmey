require 'spec_helper'

describe CarouselSlide do
  describe '#to_s' do
    it 'returns its caption' do
      expect(CarouselSlide.new(caption: 'x').to_s).to eq 'x'
    end
  end
end
