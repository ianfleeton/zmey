require 'rails_helper'

feature 'Webhooks admin' do
  let(:website) { FactoryBot.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'Create a webhook' do
    visit admin_webhooks_path
    click_link 'New'
    fill_in 'Event', with: 'image_created'
    fill_in 'URL', with: 'http://url'
    click_button 'Create Webhook'
    expect(Webhook.find_by(website_id: website.id, event: 'image_created', url: 'http://url')).to be
  end

  scenario 'Edit a webhook' do
    url = "http://#{SecureRandom.hex}"
    webhook = FactoryBot.create(:webhook, website_id: website.id)
    visit admin_webhooks_path
    click_link "Edit #{webhook}"
    fill_in 'URL', with: url
    click_button 'Update Webhook'
    expect(Webhook.find_by(url: url)).to be
  end
end
