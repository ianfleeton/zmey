require 'rails_helper'

RSpec.describe TopicsController, type: :controller do
  let(:website) { FactoryGirl.build(:website) }

  before do
    allow(controller).to receive(:website).and_return(website)
  end

  describe 'GET new' do
    let(:forum)   { FactoryGirl.create(:forum) }
    let(:admin)   { false }

    before do
      allow(controller).to receive(:admin?).and_return(admin)
      get :new, forum_id: forum.id
    end

    it 'creates a new topic belonging to the forum' do
      expect(assigns(:topic).forum).to eq forum
    end

    it 'creates a new post' do
      expect(assigns(:post)).to be_instance_of Post
    end

    context 'as admin' do
      let(:website) { FactoryGirl.build(:website, name: 'YeSL', email: 'ianf@yesl.co.uk') }
      let(:admin)   { true }

      it 'sets the post author and email from the website config' do
        expect(assigns(:post).author).to eq website.name
        expect(assigns(:post).email).to eq website.email
      end
    end
  end

  describe 'GET show' do
    it 'sets @topic' do
      topic = FactoryGirl.create(:topic)
      get :show, id: topic.id
      expect(assigns(:topic)).to eq topic
    end
  end
end
