require "rails_helper"
require_relative "expect_attachment"

RSpec.describe OrderNotifier do
  let(:website) do
    FactoryBot.create(
      :website,
      email: "sales@example.com",
      order_notifier_email: "orders@example.com",
      name: "Shop"
    )
  end
  let(:order) { FactoryBot.create(:order) }

  before do
    stub_pdf_generation
  end

  def stub_pdf_generation
    pdf = instance_double(
      PDF::Invoice,
      generate: nil,
      filename: File.join("spec", "fixtures", "pdf", "fake.pdf")
    )
    allow(PDF::Invoice).to receive(:new).and_return(pdf)
    allow(PDF::OrderConfirmationInfo).to receive(:new).and_return(pdf)
  end

  describe "#confirmation" do
    it "attaches a PDF with order confirmation and right to cancel info" do
      mail = OrderNotifier.confirmation(website, order)
      expect_attachment(mail, "InfoAndRightToCancel.pdf")
    end

    it "sends an email to the merchant's order_notifier_email" do
      mail = OrderNotifier.invoice(website, order)
      expect(mail.to).to include("orders@example.com")
    end

    it "updates order confirmation sent at field and stores it" do
      email = OrderNotifier.confirmation(website, order)
      email.deliver_now
      expect(order.confirmation_sent_at).to be_within(2.seconds).of Time.current
      order.reload
      expect(order.confirmation_sent_at).to be_within(2.seconds).of Time.current
    end

    it "does not update the confirmation confirmation_sent_at field if the record is new" do
      order = Order.new
      email = OrderNotifier.confirmation(website, order)
      email.deliver_now
      expect(order.confirmation_sent_at).to be_nil
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

  include ExpectAttachment
end
