def sign_in_as_admin
  sign_in_as(FactoryGirl.create(:admin))
end

def sign_in_as(user)
  visit '/sessions/new'
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign In'
end
