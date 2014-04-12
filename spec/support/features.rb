def sign_in_as_admin
  admin = FactoryGirl.create(:admin)
  visit '/sessions/new'
  fill_in 'Email', with: admin.email
  fill_in 'Password', with: admin.password
  click_button 'Sign In'
end
