require 'rails_helper'

feature 'Websites admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    website
    sign_in_as_admin
  end

  scenario 'Create website' do
    visit admin_websites_path
    click_link 'New Website'
    name = SecureRandom.hex
    fill_in 'Name', with: name
    fill_in 'Email', with: 'merchant@example.com'

    fill_in 'Address line 1', with: '123 Street'
    fill_in 'Address line 2', with: 'Balby'
    fill_in 'Town city', with: 'Doncaster'
    fill_in 'County', with: 'South Yorkshire'
    fill_in 'Postcode', with: 'DN4 9ZZ'
    select 'United Kingdom', from: 'Country'

    fill_in 'Subdomain', with: 'www'

    click_button 'Create New Website'
    expect(Website.find_by(name: name)).to be
  end

  scenario 'Delete website' do
    website_to_delete = FactoryGirl.create(:website)
    visit admin_websites_path
    click_link "Delete #{website_to_delete}"
    expect(Website.find_by(id: website_to_delete.id)).to be_nil
  end

  scenario 'Edit Sage Pay settings' do
    visit edit_admin_website_path(website)

    vendor = SecureRandom.hex
    pre_shared_key = SecureRandom.hex
    active = [true, false].sample
    test_mode = [true, false].sample

    fill_in 'website_sage_pay_vendor', with: vendor
    fill_in 'website_sage_pay_pre_shared_key', with: pre_shared_key
    choose "website_sage_pay_active_#{active}"
    choose "website_sage_pay_test_mode_#{test_mode}"
    click_button 'Save'

    expect(Website.find_by(
      sage_pay_vendor: vendor,
      sage_pay_pre_shared_key: pre_shared_key,
      sage_pay_active: active,
      sage_pay_test_mode: test_mode
    )).to be
  end

  scenario 'Edit SMTP settings' do
    visit edit_admin_website_path(website)

    active   = [true, false].sample
    host     = SecureRandom.hex
    username = SecureRandom.hex
    password = SecureRandom.hex
    port     = [25, 587].sample

    fill_in 'website_smtp_host',     with: host
    fill_in 'website_smtp_username', with: username
    fill_in 'website_smtp_password', with: password
    fill_in 'website_smtp_port',     with: port
    choose "website_smtp_active_#{active}"
    click_button 'Save'

    expect(Website.find_by(
      smtp_host:     host,
      smtp_username: username,
      smtp_password: password,
      smtp_port:     port,
      smtp_active:   active
    )).to be
  end
end
