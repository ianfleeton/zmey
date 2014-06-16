require 'spec_helper'

feature 'Users admin' do
  let(:website) { FactoryGirl.create(:website) }
  let(:user)    { FactoryGirl.create(:user, website_id: website.id) }
  let(:address) { FactoryGirl.create(:address, user_id: user.id) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'Delete user' do
    user

    visit admin_users_path
    click_link "Delete #{user}"

    expect(User.find_by(id: user.id)).to be_nil
    expect(current_path).to eq admin_users_path
  end

  scenario 'View user addresses' do
    address

    visit admin_user_path(user)
    click_link I18n.t('admin.users.show.addresses')
    expect(page).to have_content(address.address_line_1)
  end

  scenario 'Delete user address' do
    address

    visit admin_user_addresses_path(user)
    click_link "Delete #{address}"
    expect(Address.find_by(address.id)).to be_nil
    expect(current_path).to eq admin_user_addresses_path(user)
  end

  scenario 'Edit user address' do
    address

    new_address_line_1 = SecureRandom.hex

    visit admin_user_addresses_path(user)
    click_link "Edit #{address}"
    fill_in 'Address line 1', with: new_address_line_1
    click_button "Update Address"

    address.reload
    expect(address.address_line_1).to eq new_address_line_1
  end
end
