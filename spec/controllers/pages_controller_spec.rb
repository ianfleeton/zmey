require 'spec_helper'

describe PagesController do
  describe 'GET show' do
    let(:website) { FactoryGirl.create(:website) }
    let(:slug)    { 'slug' }
    before { controller.stub(:website).and_return(website) }

    it 'finds a page by its slug and the current website' do
      Page.should_receive(:find_by).with hash_including(slug: slug, website_id: website)
      get :show, slug: slug
    end

    context 'when page found' do
      it 'sets @title and @description from the page' do
        title       = 'title'
        description = 'description'
        Page.stub(:find_by).and_return(
          mock_model(Page, title: title, description: description)
          .as_null_object
        )
        get :show, slug: slug
        expect(assigns(:title)).to eq title
        expect(assigns(:description)).to eq description
      end
    end

    context 'when page not found' do
      before { Page.stub(:find_by).and_return(nil) }

      it 'renders 404' do
        get :show, slug: slug
        expect(response.status).to eq 404
      end
    end
  end

  describe 'GET terms' do
    it 'populates @terms from the website config' do
      controller.stub(:website).and_return(
        mock_model(Website, terms_and_conditions: 'T&C', build_custom_view_resolver: nil)
      )
      get :terms
      expect(assigns(:terms)).to eq 'T&C'
    end
  end
end
