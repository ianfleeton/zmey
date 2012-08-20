class UserNotifier < ActionMailer::Base
  def token website, user
    subject website.name + ': how to change your password'
    recipients user.email
    from website.email
    sent_on Time.now
    body domain: website.domain, id: user.id, name: user.name,
      token: user.forgot_password_token
  end
end
