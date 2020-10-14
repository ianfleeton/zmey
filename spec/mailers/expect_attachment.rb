# frozen_string_literal: true

module ExpectAttachment
  def expect_attachment(mail, filename)
    expect(mail.attachments.length).to eq 1
    attachment = mail.attachments[0]
    expect(attachment.content_type).to start_with("application/pdf;")
    expect(attachment.filename).to eq filename
  end
end
