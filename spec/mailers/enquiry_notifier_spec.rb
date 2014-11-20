require 'rails_helper'

describe EnquiryNotifier do
  it 'sets delivery settings' do
    host = 'example.org'
    user = 'user'
    pass = 'secret'
    port = 587

    website = Website.new(
      smtp_active: true,
      smtp_host: host,
      smtp_username: user,
      smtp_password: pass,
      smtp_port: port
    )
    mail = EnquiryNotifier.enquiry(website, Enquiry.new)
    expect(mail.delivery_method.settings).to eq({
      address: host,
      password: pass,
      port: port,
      user_name: user
    })
  end
end
