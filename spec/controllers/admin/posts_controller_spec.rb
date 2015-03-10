require 'rails_helper'

RSpec.describe Admin::PostsController, type: :controller do
  before do
    FactoryGirl.create(:website)
    allow(controller).to receive(:admin?).and_return(true)
  end

  describe 'GET edit' do
    it 'sets @post' do
      post = FactoryGirl.create(:post)
      get :edit, id: post.id
      expect(assigns(:post)).to eq post
    end
  end

  describe 'PATCH update' do
    let(:post) { FactoryGirl.create(:post) }

    before do
      patch :update, id: post.id, post: post_params
    end

    context 'when success' do
      let(:post_params) { { author: 'A. Uther', content: 'Updated', email: 'author@example.org' } }

      it 'updates the post' do
        expect(post.reload.content).to eq 'Updated'
      end

      it "redirects to the post's topic" do
        expect(response).to redirect_to post.topic
      end
    end

    context 'when fail' do
      let(:post_params) { { author: '', content: '', email: '' } }

      it 'renders edit' do
        expect(response).to render_template :edit
      end
    end
  end
end
