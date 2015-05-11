require 'rails_helper'

describe PagesController do
  describe 'GET show' do
    let(:website) { FactoryGirl.create(:website) }
    let(:slug)    { 'slug' }
    before { allow(controller).to receive(:website).and_return(website) }

    it 'finds a page by its slug' do
      expect(Page).to receive(:find_by).with hash_including(slug: slug)
      get :show, slug: slug
    end

    context 'when page found' do
      let(:title)       { 'title' }
      let(:description) { 'description' }

      before do
        allow(Page).to receive(:find_by).and_return(
          double(Page, title: title, description: description)
          .as_null_object
        )
      end

      it 'sets @title and @description from the page' do
        get :show, slug: slug
        expect(assigns(:title)).to eq title
        expect(assigns(:description)).to eq description
      end

      context 'when not XHR' do
        it 'renders with layout' do
          get :show, slug: slug
          expect(response).to render_template('application')
        end
      end

      context 'when XHR' do
        it 'renders without layout' do
          xhr :get, :show, slug: slug
          expect(response).not_to render_template('application')
        end
      end
    end

    context 'when page not found' do
      before { allow(Page).to receive(:find_by).and_return(nil) }

      it 'renders 404' do
        get :show, slug: slug
        expect(response.status).to eq 404
      end
    end
  end

  describe 'GET terms' do
    it 'populates @terms from the website config' do
      allow(controller).to receive(:website).and_return(
        FactoryGirl.build(:website, terms_and_conditions: 'T&C')
      )
      get :terms
      expect(assigns(:terms)).to eq 'T&C'
    end
  end
end
