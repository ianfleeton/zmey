class UserNotifier < ActionMailer::Base
  include EmailSetup

  def token(website, user)
    setup(website, user)

    @token = user.forgot_password_token
    mail(
      to: user.email,
      subject: "#{website.name}: how to change your password",
      from: website.email_address
    )
  end

  def email_verification(website, user)
    setup(website, user)

    @token = user.email_verification_token
    mail(
      to: user.email,
      subject: "#{website.name}: please verify your email",
      from: website.email_address
    )
  end

  def password_changed(website, user)
    setup(website, user)

    mail(
      to: user.email,
      subject: "#{website.name}: your password has been changed",
      from: website.email_address
    )
  end

  private

  def setup(website, user)
    @website = website

    @domain = website.domain
    @id = user.id
    @name = user.name
  end
end
