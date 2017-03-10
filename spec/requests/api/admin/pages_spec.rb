require 'rails_helper'

describe 'Admin pages API' do
  before do
    prepare_api_website
  end

  describe 'GET index' do
    context 'with pages' do
      before do
        @page1 = FactoryGirl.create(:page)
        @page2 = FactoryGirl.create(:page, parent_id: @page1.id)
      end

      it 'returns all pages' do
        get '/api/admin/pages'

        pages = JSON.parse(response.body)

        expect(pages['pages'].length).to eq 2
        expect(pages['pages'][0]['id']).to eq @page1.id
        expect(pages['pages'][0]['href']).to eq api_admin_page_url(@page1)
        expect(pages['pages'][1]['parent_id']).to eq @page1.id
        expect(pages['pages'][0]['slug']).to eq @page1.slug
        expect(pages['pages'][0]['title']).to eq @page1.title
      end

      it 'returns 200 OK' do
        get '/api/admin/pages'
        expect(response.status).to eq 200
      end
    end

    context 'with no pages' do
      it 'returns 200 OK' do
        get '/api/admin/pages'
        expect(response.status).to eq 200
      end

      it 'returns an empty set' do
        get '/api/admin/pages'
        pages = JSON.parse(response.body)
        expect(pages['pages'].length).to eq 0
      end
    end
  end

  describe 'GET show' do
    context 'when page found' do
      before do
        @page = FactoryGirl.create(:page)
      end

      it 'returns 200 OK' do
        get api_admin_page_path(@page)
        expect(response.status).to eq 200
      end
    end

    context 'when no page' do
      it 'returns 404 Not Found' do
        get '/api/admin/pages/0'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST create' do
    it 'inserts a new page' do
      name = SecureRandom.hex
      slug = SecureRandom.hex
      title = SecureRandom.hex
      image = FactoryGirl.create(:image)
      visible = [true, false].sample
      description = 'Description'
      post '/api/admin/pages', params: { page: {description: description, image_id: image.id, name: name, slug: slug, thumbnail_image_id: image.id, title: title, visible: visible} }
      expect(Page.find_by(slug: slug, image_id: image.id, thumbnail_image_id: image.id, visible: visible)).to be
    end

    it 'returns 422 with bad params' do
      post '/api/admin/pages', params: { page: { title: '' } }
      expect(response.status).to eq 422
    end
  end

  describe 'DELETE delete_all' do
    it 'deletes all pages' do
      page_1 = FactoryGirl.create(:page)
      page_2 = FactoryGirl.create(:page, parent_id: page_1.id)
      page_1.save!
      page_2.save!

      delete '/api/admin/pages'

      expect(Page.find_by(id: page_1.id)).not_to be
      expect(Page.find_by(id: page_2.id)).not_to be
    end

    it 'responds with 204 No Content' do
      delete '/api/admin/pages'

      expect(status).to eq 204
    end
  end
end
