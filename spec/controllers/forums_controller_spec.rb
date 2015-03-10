require 'rails_helper'

RSpec.describe ForumsController, type: :controller do
  before { FactoryGirl.create(:website) }

  describe 'GET show' do
    it 'assigns @forum topics to @topics' do
      forum = FactoryGirl.create(:forum)
      topic = FactoryGirl.create(:topic, forum: forum)
      get :show, id: forum.id
      expect(assigns(:topics)).to include(topic)
    end
  end
end
