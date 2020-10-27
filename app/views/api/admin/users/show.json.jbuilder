json.user do
  json.id @user.id
  json.href api_admin_user_url(@user)
  json.name @user.name
  json.email @user.email
  json.encrypted_password @user.encrypted_password
  json.salt @user.salt
  json.forgot_password_token @user.forgot_password_token
  json.customer_reference @user.customer_reference
  json.created_at @user.created_at
  json.updated_at @user.updated_at
end
