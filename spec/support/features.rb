def sign_in_as_admin
  sign_in_as(FactoryGirl.create(:admin))
end

def sign_in_as(user)
  visit '/sessions/new'
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Sign In'
end

# Checks <tt>check_box</tt> when <tt>value</tt> is <tt>true</tt>, otherwise
# unchecks it.
def check_or_uncheck(check_box, value)
  value ? check(check_box) : uncheck(check_box)
end
