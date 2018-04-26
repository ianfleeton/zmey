require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  describe 'GET show' do
    let(:website) { FactoryBot.create(:website) }
    let(:slug)    { 'slug' }
    before { allow(controller).to receive(:website).and_return(website) }

    it 'finds a page by its slug' do
      expect(Page).to receive(:find_by).with hash_including(slug: slug)
      get :show, params: { slug: slug }
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
    end

    context 'when page not found' do
      before { allow(Page).to receive(:find_by).and_return(nil) }

      it 'renders 404' do
        get :show, params: { slug: slug }
        expect(response.status).to eq 404
      end
    end
  end
end
