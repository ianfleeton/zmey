require "rails_helper"

RSpec.describe OrderNotifier do
  let(:website) { FactoryBot.build(:website) }
  let(:order) { FactoryBot.build(:order) }

  describe "#notification" do
    it "works" do
      OrderNotifier.notification(website, order).deliver_now
    end
  end

  describe "#invoice" do
    let(:website) { FactoryBot.create(:website) }

    before do
      order.order_number = 123
    end

    it "includes an attached PDF invoice" do
      mail = OrderNotifier.invoice(website, order)
      expect(mail.attachments.length).to eq 1
      attachment = mail.attachments[0]
      expect(attachment.content_type).to start_with("application/pdf;")
      expect(attachment.filename).to eq "Order 123 - Invoice.pdf"
    end
  end

  describe "#admin_waiting_for_payment" do
    it "works" do
      OrderNotifier.admin_waiting_for_payment(website, order).deliver_now
    end
  end
end
