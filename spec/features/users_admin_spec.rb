require 'spec_helper'

feature 'Users admin' do
  let(:website) { FactoryGirl.create(:website) }

  background do
    Website.delete_all
    website
    sign_in_as_admin
  end

  scenario 'Delete user' do
    user = FactoryGirl.create(:user, website_id: website.id)

    visit admin_users_path
    click_link "Delete #{user}"

    expect(User.find_by(id: user.id)).to be_nil
    expect(current_path).to eq admin_users_path
  end

  scenario 'View user addresses' do
    user = FactoryGirl.create(:user, website_id: website.id)
    address = FactoryGirl.create(:address, user_id: user.id)

    visit admin_user_path(user)
    click_link I18n.t('admin.users.show.addresses')
    expect(page).to have_content(address.address_line_1)
  end
end
