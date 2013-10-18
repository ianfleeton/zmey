def sign_in_as_admin
  FactoryGirl.create(:admin)
  visit '/sessions/new'
  fill_in 'Email', with: 'admin@example.org'
  fill_in 'Password', with: 'secret'
  click_button 'Sign In'
end
