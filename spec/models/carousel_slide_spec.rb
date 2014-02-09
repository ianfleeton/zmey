require 'spec_helper'

describe CarouselSlide do
  describe '#to_s' do
    it 'returns its caption' do
      expect(CarouselSlide.new(caption: 'x').to_s).to eq 'x'
    end
  end

  describe '#ensure_active_range' do
    it 'sets active_from and active_until if they are nil' do
      cs = CarouselSlide.new
      cs.save
      expect(cs.active_from).to be < Date.today
      expect(cs.active_until).to be > Date.today + 1.year
    end
  end
end
