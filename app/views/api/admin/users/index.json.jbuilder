json.users(@users) do |user|
  json.id     user.id
  json.href   api_admin_user_url(user)
  json.name   user.name
  json.email  user.email
end
