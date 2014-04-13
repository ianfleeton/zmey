require 'spec_helper'

def prepare_api_website
  @website = FactoryGirl.create(:website)
  @api_user = FactoryGirl.create(:user, manages_website_id: @website.id)
  @api_key = FactoryGirl.create(:api_key, user_id: @api_user.id)
end

describe 'Admin pages API' do
  before do
    prepare_api_website
    Api::Admin::AdminController.any_instance.stub(:authenticated_api_key).and_return(@api_key)
  end

  describe 'GET index' do
    context 'with pages' do
      before do
        @page1 = FactoryGirl.create(:page, website_id: @website.id)
        @page2 = FactoryGirl.create(:page, parent_id: @page1.id, website_id: @website.id)
        @page3 = FactoryGirl.create(:page)
      end

      it 'returns pages for the website' do
        get 'api/admin/pages'

        pages = JSON.parse(response.body)

        expect(pages['pages'].length).to eq 2
        expect(pages['pages'][0]['id']).to eq @page1.id
        expect(pages['pages'][1]['parent_id']).to eq @page1.id
        expect(pages['pages'][0]['slug']).to eq @page1.slug
        expect(pages['pages'][0]['title']).to eq @page1.title
      end

      it 'returns 200 OK' do
        get 'api/admin/pages'
        expect(response.status).to eq 200
      end
    end

    context 'with no pages' do
      it 'returns 404 Not Found' do
        get 'api/admin/pages'
        expect(response.status).to eq 404
      end
    end
  end

  describe 'POST create' do
    it 'inserts a new page into the website' do
      name = SecureRandom.hex
      slug = SecureRandom.hex
      title = SecureRandom.hex
      description = 'Description'
      post 'api/admin/pages', page: {description: description, name: name, slug: slug, title: title}
      expect(Page.find_by(slug: slug, website: @website)).to be
    end
  end
end
