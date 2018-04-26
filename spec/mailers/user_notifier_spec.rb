require 'rails_helper'

describe UserNotifier do
  let(:website) { FactoryBot.build(:website) }
  let(:user) { FactoryBot.build(:user) }

  describe 'token' do
    it 'works' do
      UserNotifier.token(website, user).deliver_now
    end
  end
end
