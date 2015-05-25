require 'rails_helper'

RSpec.describe SendEmailsJob, type: :job do
  describe '#perform' do
    it 'sends dispatch notification emails' do
      expect_email_sending(from: DispatchNotifier, ignore: [InvoiceNotifier])
      SendEmailsJob.new.perform
    end

    it 'sends invoice notification emails' do
      expect_email_sending(from: InvoiceNotifier, ignore: [DispatchNotifier])
      SendEmailsJob.new.perform
    end

    def expect_email_sending(params)
      sender = params[:from]
      ignore = params[:ignore]

      ignore.each do |ignored|
        allow(ignored).to receive(:new).and_return(double(ignored).as_null_object)
      end

      notifier = double(sender)
      expect(notifier).to receive(:send_emails)
      allow(sender).to receive(:new).and_return(notifier)
    end
  end
end
