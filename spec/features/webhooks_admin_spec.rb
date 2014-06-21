require 'spec_helper'

feature 'Webhooks admin' do
  let(:website) { FactoryGirl.create(:website) }

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
    expect(Webhook.find_by(website: website, event: 'image_created', url: 'http://url')).to be
  end
end
