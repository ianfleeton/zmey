require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:orders).dependent(:nullify) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:customer_reference).allow_blank }
  end

  describe "passwords" do
    it "stores a bcrypt digest" do
      user = FactoryBot.create(:user, password: "topsecret")
      expect(BCrypt::Password.new(user.password_digest)).to eq "topsecret"
    end

    it "authenticates with the right password only" do
      user = FactoryBot.create(:user, password: "topsecret")
      expect(User.authenticate_by(email: user.email, password: "topsecret")).to eq user
      expect(User.authenticate_by(email: user.email, password: "wrong")).to be_nil
    end

    it "never authenticates an account without a password" do
      user = FactoryBot.create(:user, password: nil)
      expect(user.password_set?).to be false
      expect(User.authenticate_by(email: user.email, password: "")).to be_nil
    end

    it "rejects passwords shorter than 8 characters" do
      expect(FactoryBot.build(:user, password: "short")).not_to be_valid
    end

    it "rejects passwords longer than bcrypt's 72 byte limit" do
      expect(FactoryBot.build(:user, password: "a" * 73)).not_to be_valid
    end
  end

  describe ".find_or_create_by_details" do
    it "returns an existing user if a matching email is found" do
      existing = FactoryBot.create(:user, email: "matched@example.com")
      expect(
        User.find_or_create_by_details(
          email: "matched@example.com", name: "Alice"
        )
      ).to eq existing
    end

    it "finds by email case-insensitively" do
      existing = FactoryBot.create(:user, email: "matched@example.com")
      expect(
        User.find_or_create_by_details(
          email: "MATCHED@example.com", name: "Alice"
        )
      ).to eq existing
    end

    it "creates a new user with given details when no matching customer " \
    "found" do
      u = User.find_or_create_by_details(
        email: "notfound@example.com", name: "Alice"
      )
      expect(u.persisted?).to be_truthy
      expect(u.name).to eq "Alice"
      expect(u.password_set?).to be false
    end

    it "returns unpersisted user and does not touch the database for a nil email" do
      expect(User).not_to receive(:find_by)
      user = User.find_or_create_by_details(email: nil, name: "Alice")
      expect(user).to be_instance_of(User)
      expect(user.persisted?).to be_falsey
    end
  end
end
