require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "#current_user" do
    it "returns a user identified by session[:user]" do
      user = FactoryBot.create(:user)
      session[:user] = user.id
      expect(controller.current_user).to eq user
    end

    it "returns a new user when no valid user in session" do
      expect(controller.current_user).to be_instance_of User
      expect(controller.current_user.new_record?).to be_truthy
    end
  end

  describe "#website" do
    subject { controller.website }

    context "with no website in database" do
      it { should be_instance_of(Website) }
      it { should be_new_record }
    end
  end

  describe "#logged_in?" do
    it "returns true when current_user is persisted" do
      allow(controller).to receive(:current_user)
        .and_return(FactoryBot.create(:user))
      expect(controller.logged_in?).to be_truthy
    end

    it "returns false when current_user is a new record" do
      allow(controller).to receive(:current_user).and_return(User.new)
      expect(controller.logged_in?).to be_falsey
    end
  end
end
