require 'rails_helper'

describe 'Admin carousel slides API' do
  before do
    prepare_api_website
  end

  describe 'DELETE delete_all' do
    before do
      @carousel_slide1 = FactoryGirl.create(:carousel_slide, website_id: @website.id)
      @carousel_slide2 = FactoryGirl.create(:carousel_slide)
    end

    it 'deletes all carousel slides in the website' do
      delete '/api/admin/carousel_slides'
      expect(CarouselSlide.find_by(id: @carousel_slide1.id)).to be_nil
      expect(CarouselSlide.find_by(id: @carousel_slide2.id)).to be
    end

    it 'returns 204 No Content' do
      delete '/api/admin/carousel_slides'
      expect(response.status).to eq 204
    end
  end
end
