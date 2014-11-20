require 'concerns/email_setup'

class UserNotifier < ActionMailer::Base
  include EmailSetup

  def token(website, user)
    @website = website
    @domain = website.domain
    @id = user.id
    @name = user.name
    @token = user.forgot_password_token
    mail(to: user.email, subject: "#{website.name}: how to change your password", from: website.email)
  end
end
