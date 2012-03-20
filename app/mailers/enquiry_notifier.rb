class EnquiryNotifier < ActionMailer::Base
  def enquiry website, e
    @name = e.name
    @organisation = e.organisation
    @address = e.address
    @country = e.country
    @postcode = e.postcode
    @telephone = e.telephone
    @email = e.email
    @fax = e.fax
    @enquiry = e.enquiry
    @call_back = e.call_back
    @hear_about = e.hear_about

    mail(to: [website.email], subject: website.name + ': enquiry sent', from: website.email)
  end
end
