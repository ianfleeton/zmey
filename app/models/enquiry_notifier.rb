class EnquiryNotifier < ActionMailer::Base
  def enquiry website, e
    subject website.name + ': enquiry sent'
    recipients website.email
    from website.email
    sent_on Time.now
    body :name => e.name,
      :organisation => e.organisation,
      :address => e.address,
      :country => e.country,
      :postcode => e.postcode,
      :telephone => e.telephone,
      :email => e.email,
      :fax => e.fax,
      :enquiry => e.enquiry,
      :call_back => e.call_back,
      :hear_about => e.hear_about
  end
end
