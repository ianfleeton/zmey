class BasketMailer < ActionMailer::Base
  def saved_basket(website, email_address, basket)
    @website = website
    @basket  = basket
    mail(to: email_address, from: website.email)
  end
end
