require 'rails_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin carousel slides API' do
  before do
    prepare_api_website
    allow_any_instance_of(Api::Admin::AdminController).to receive(:authenticated_api_key).and_return(@api_key)
  end

  describe 'DELETE delete_all' do
    before do
      @carousel_slide1 = FactoryGirl.create(:carousel_slide, website_id: @website.id)
      @carousel_slide2 = FactoryGirl.create(:carousel_slide)
    end

    it 'deletes all carousel slides in the website' do
      delete 'api/admin/carousel_slides'
      expect(CarouselSlide.find_by(id: @carousel_slide1.id)).to be_nil
      expect(CarouselSlide.find_by(id: @carousel_slide2.id)).to be
    end

    it 'returns 204 No Content' do
      delete 'api/admin/carousel_slides'
      expect(response.status).to eq 204
    end
  end
end
