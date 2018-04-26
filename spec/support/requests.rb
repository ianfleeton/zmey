def prepare_api_website
  @website = FactoryBot.create(:website)
  @api_user = FactoryBot.create(:user, manages_website_id: @website.id)
  @api_key = FactoryBot.create(:api_key, user_id: @api_user.id)
  allow_any_instance_of(Api::Admin::AdminController).to receive(:authenticated_api_key).and_return(@api_key)
end
