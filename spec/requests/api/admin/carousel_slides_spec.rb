require 'rails_helper'

describe 'Admin carousel slides API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    it 'inserts a new slide into the website' do
      params = {
        caption: SecureRandom.hex,
        image_id: FactoryGirl.create(:image).id,
        link: SecureRandom.hex,
        active_from: '2015-01-01 00:00:00',
        active_until: '2015-02-02 23:59:59',
        html: '<h2>Sale now on!</h2>'
      }
      post '/api/admin/carousel_slides', carousel_slide: params
      expect(CarouselSlide.find_by(params)).to be
    end

    it 'returns 422 with bad params' do
      post '/api/admin/carousel_slides', carousel_slide: {caption: ''}
      expect(response.status).to eq 422
    end
  end

  describe 'DELETE delete_all' do
    before do
      @carousel_slide = FactoryGirl.create(:carousel_slide)
    end

    it 'deletes all carousel slides in the website' do
      delete '/api/admin/carousel_slides'
      expect(CarouselSlide.any?).to be_falsey
    end

    it 'returns 204 No Content' do
      delete '/api/admin/carousel_slides'
      expect(response.status).to eq 204
    end
  end
end
