class UserNotifier < ActionMailer::Base
  def token(website, user)
    @domain = website.domain
    @id = user.id
    @name = user.name
    @token = user.forgot_password_token
    mail(to: user.email, subject: "#{website.name}: how to change your password", from: website.email)
  end
end
