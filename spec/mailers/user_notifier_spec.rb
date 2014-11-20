require 'rails_helper'

describe UserNotifier do
  let(:website) { FactoryGirl.build(:website) }
  let(:user) { FactoryGirl.build(:user) }

  describe 'token' do
    it 'works' do
      UserNotifier.token(website, user).deliver_now
    end
  end
end
