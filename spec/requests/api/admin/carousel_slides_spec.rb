require 'rails_helper'

describe 'Admin carousel slides API' do
  before do
    prepare_api_website
  end

  describe 'POST create' do
    it 'inserts a new slide into the website' do
      caption = SecureRandom.hex
      image = FactoryGirl.create(:image)
      link = SecureRandom.hex

      post '/api/admin/carousel_slides', carousel_slide: {caption: caption, image_id: image.id, link: link}
      expect(CarouselSlide.find_by(caption: caption, image_id: image.id, link: link)).to be
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
