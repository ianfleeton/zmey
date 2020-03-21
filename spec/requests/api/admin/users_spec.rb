require "rails_helper"

describe "Admin users API" do
  before do
    prepare_api_website
  end

  describe "GET index" do
    let(:json) { JSON.parse(response.body) }
    let(:num_items) { 1 }
    let(:email) { nil }

    # +more_setup+ lambda allows more setup in the outer before block.
    let(:more_setup) { nil }

    before do
      num_items.times do |x|
        FactoryBot.create(:user)
      end

      @user1 = User.first

      more_setup.try(:call)

      get "/api/admin/users", params: {email: email}
    end

    context "with users" do
      it "returns users for the website" do
        expect(json["users"].length).to eq 2 # 1 set up + admin
        user = json["users"][0]
        expect(user["id"]).to eq @user1.id
        expect(user["href"]).to eq api_admin_user_url(@user1)
        expect(user["name"]).to eq @user1.name
        expect(user["email"]).to eq @user1.email
      end

      it "returns 200 OK" do
        expect(response.status).to eq 200
      end
    end

    context "with email set" do
      let(:email) { "#{SecureRandom.hex}@example.org" }

      let!(:more_setup) {
        -> {
          @matching_user = FactoryBot.create(:user)
          @matching_user.email = email
          @matching_user.save
        }
      }

      it "returns the matching email" do
        expect(json["users"].length).to eq 1
        expect(json["users"][0]["email"]).to eq @matching_user.email
      end
    end

    context "with no matching users" do
      let(:email) { "nonexistent@example.org" }

      it "returns 200 OK" do
        expect(response.status).to eq 200
      end

      it "returns an empty set" do
        expect(json["users"].length).to eq 0
      end
    end
  end

  describe "GET show" do
    context "when user found" do
      let(:manages_website_id) { nil }

      before do
        @user = FactoryBot.create(:user, manages_website_id: manages_website_id)
      end

      it "returns 200 OK" do
        get api_admin_user_path(@user)
        expect(response.status).to eq 200
      end

      context "when user does not manage current website" do
        it "sets manager to false" do
          get api_admin_user_path(@user)
          user = JSON.parse(response.body)
          expect(user["user"]["manager"]).to be_falsey
        end
      end

      context "when user manages current website" do
        let(:manages_website_id) { @website.id }

        it "sets manager to true" do
          get api_admin_user_path(@user)
          user = JSON.parse(response.body)
          expect(user["user"]["manager"]).to be_truthy
        end
      end
    end

    context "when no user" do
      it "returns 404 Not Found" do
        get "/api/admin/users/0"
        expect(response.status).to eq 404
      end
    end
  end

  describe "PATCH update" do
    let(:customer_reference) { "ABUY1234" }

    before do
      patch api_admin_user_path(user), params: {user: {customer_reference: customer_reference}}
    end

    context "when user found" do
      let(:user) { FactoryBot.create(:user) }

      it "responds with 204 No Content" do
        expect(status).to eq 204
      end

      it "updates a user" do
        expect(User.find(user.id).customer_reference).to eq customer_reference
      end
    end

    context "when user not found" do
      let(:user) do
        u = FactoryBot.create(:user)
        u.id += 1
        u
      end

      it "responds 404 Not Found" do
        expect(status).to eq 404
      end
    end
  end
end
