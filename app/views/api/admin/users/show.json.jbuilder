json.user do
  json.id @user.id
  json.href api_admin_user_url(@user)
  json.name @user.name
  json.email @user.email
  json.customer_reference @user.customer_reference
  json.communication_preferences_token @user.generate_token_for(:communication_preferences)
  json.created_at @user.created_at
  json.updated_at @user.updated_at
end
