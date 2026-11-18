require "rails_helper"

RSpec.describe DispatchNotifier do
  let(:dn) { DispatchNotifier.new }

  describe "#pending_objects" do
    let(:pending) { FactoryBot.create(:shipment, shipped_at: Date.today, email_sent_at: nil) }
    let(:already_sent) { FactoryBot.create(:shipment, shipped_at: Date.today, email_sent_at: Date.today) }
    let(:unshipped) { FactoryBot.create(:shipment, shipped_at: nil) }

    it "returns only shipments pending dispatch notifications" do
      shipments = dn.pending_objects
      expect(shipments).to include(pending)
      expect(shipments).not_to include(already_sent)
      expect(shipments).not_to include(unshipped)
    end
  end

  describe "#send_email" do
    before { FactoryBot.create(:website) }
    let(:shipment) { FactoryBot.create(:shipment) }

    it "sends a dispatch notification email" do
      expect { dn.send_email(shipment) }
        .to change { ActionMailer::Base.deliveries.count }
        .by(1)
    end
  end

  describe "#claim" do
    let(:shipment) { FactoryBot.create(:shipment, email_sent_at: nil) }

    it "sets the shipment's email_sent_at attribute and saves it" do
      expect(dn.claim(shipment)).to be true
      expect(shipment.reload.email_sent_at).to be
    end

    it "returns false if another run already claimed the shipment" do
      stale_copy = Shipment.find(shipment.id)
      dn.claim(shipment)
      expect(dn.claim(stale_copy)).to be false
    end
  end

  describe "#send_emails" do
    before { FactoryBot.create(:website) }
    let!(:shipment) { FactoryBot.create(:shipment, shipped_at: Date.today, email_sent_at: nil) }

    it "sends one email even if the shipment is listed by two overlapping runs" do
      first_run = DispatchNotifier.new
      second_run = DispatchNotifier.new
      allow(second_run).to receive(:pending_objects).and_return([Shipment.find(shipment.id)])
      expect {
        first_run.send_emails
        second_run.send_emails
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it "releases the shipment for a later run if sending fails" do
      allow(dn).to receive(:send_email).and_raise(IOError)
      expect { dn.send_emails }.to raise_error(IOError)
      expect(shipment.reload.email_sent_at).to be_nil
    end
  end
end
