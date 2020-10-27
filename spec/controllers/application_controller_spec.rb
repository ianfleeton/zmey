require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  describe "#current_user" do
    it "returns a user identified by session[:user_id]" do
      user = FactoryBot.create(:user)
      session[:user_id] = user.id
      expect(controller.current_user).to eq user
    end

    it "returns a new user when no valid user in session" do
      expect(controller.current_user).to be_instance_of User
      expect(controller.current_user.new_record?).to be_truthy
    end

    it "does not hit the database if session[:user_id] is nil" do
      session[:user_id] = nil
      expect(User).not_to receive(:find_by).with(id: nil)
      controller.current_user
    end
  end

  describe "#unverified_user" do
    it "returns a user identified by session[:unverified_user_id]" do
      user = FactoryBot.create(:user)
      session[:unverified_user_id] = user.id
      expect(controller.unverified_user).to eq user
    end

    it "does not hit the database if session[:unverified_user_id] is nil" do
      session[:unverified_user_id] = nil
      expect(User).not_to receive(:find_by).with(id: nil)
      controller.unverified_user
    end

    context "when user is verified" do
      before do
        user = FactoryBot.create(:user, email_verified_at: Time.current)
        session[:unverified_user_id] = user.id
      end

      it "clears session[:unverified_user_id] when user is verified" do
        controller.unverified_user
        expect(session[:unverified_user_id]).to be_nil
      end

      it "returns nil" do
        expect(controller.unverified_user).to be_nil
      end
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
