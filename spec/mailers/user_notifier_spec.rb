require "rails_helper"

describe UserNotifier do
  let(:website) { FactoryBot.build(:website) }
  let(:user) { FactoryBot.build(:user) }

  describe "password_reset" do
    let(:user) { FactoryBot.create(:user) }

    it "links to the reset page with a token that finds the user" do
      mail = UserNotifier.password_reset(website, user)
      url = mail.body.encoded[%r{https?://\S+}]
      expect(url).to start_with("#{website.scheme}://#{website.domain}/account/forgot_password/new?t=")
      token = Rack::Utils.parse_query(URI(url).query)["t"]
      expect(User.find_by_password_reset_token(token)).to eq user
    end
  end
end
