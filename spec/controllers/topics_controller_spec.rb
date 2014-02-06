require 'spec_helper'

describe TopicsController do
  describe 'GET new' do
    let(:forum)   { FactoryGirl.create(:forum) }
    let(:website) { mock_model(Website) }
    let(:admin)   { false }

    before do
      controller.stub(:website).and_return(website)
      controller.stub(:admin?).and_return(admin)
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
end
