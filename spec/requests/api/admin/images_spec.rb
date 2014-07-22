require 'spec_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin images API' do
  before do
    prepare_api_website
    Api::Admin::AdminController.any_instance.stub(:authenticated_api_key).and_return(@api_key)
  end

  describe 'GET index' do
    context 'with images' do
      before do
        @image1 = FactoryGirl.create(:image, website_id: @website.id)
        @image2 = FactoryGirl.create(:image)
      end

      it 'returns images for the website' do
        get 'api/admin/images'

        images = JSON.parse(response.body)

        expect(images['images'].length).to eq 1
        expect(images['images'][0]['id']).to eq @image1.id
        expect(images['images'][0]['filename']).to eq @image1.filename
        expect(images['images'][0]['name']).to eq @image1.name
      end

      it 'returns 200 OK' do
        get 'api/admin/images'
        expect(response.status).to eq 200
      end
    end

    context 'with no images' do
      it 'returns 200 OK' do
        get 'api/admin/images'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get 'api/admin/images'
        images = JSON.parse(response.body)
        expect(images['images'].length).to eq 0
      end
    end
  end

  describe 'DELETE delete_all' do
    before do
      @image1 = FactoryGirl.create(:image, website_id: @website.id)
      @image2 = FactoryGirl.create(:image)
    end

    context 'with no DeleteRestrictionErrors' do
      it 'deletes all images in the website' do
        delete 'api/admin/images'
        expect(Image.find_by(id: @image1.id)).to be_nil
        expect(Image.find_by(id: @image2.id)).to be
      end

      it 'returns 204 No Content' do
        delete 'api/admin/images'
        expect(response.status).to eq 204
      end
    end

    context 'with DeleteRestrictionError' do
      it 'returns 400 Bad Request' do
        FactoryGirl.create(:carousel_slide, image_id: @image1.id, website_id: @website.id)
        delete 'api/admin/images'
        expect(response.status).to eq 400
      end
    end
  end
end
