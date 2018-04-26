require 'rails_helper'

RSpec.describe DispatchNotifier do
  let(:dn) { DispatchNotifier.new }

  describe '#pending_objects' do
    let(:pending) { FactoryBot.create(:shipment, shipped_at: Date.today, email_sent_at: nil) }
    let(:already_sent) { FactoryBot.create(:shipment, shipped_at: Date.today, email_sent_at: Date.today) }
    let(:unshipped) { FactoryBot.create(:shipment, shipped_at: nil) }

    it 'returns only shipments pending dispatch notifications' do
      shipments = dn.pending_objects
      expect(shipments).to include(pending)
      expect(shipments).not_to include(already_sent)
      expect(shipments).not_to include(unshipped)
    end
  end

  describe '#send_email' do
    before { FactoryBot.create(:website) }
    let(:shipment) { FactoryBot.create(:shipment) }

    it 'sends a dispatch notification email' do
      expect { dn.send_email(shipment) }
        .to change { ActionMailer::Base.deliveries.count }
        .by(1)
    end
  end

  describe '#record_sent' do
    let(:shipment) { FactoryBot.create(:shipment, email_sent_at: nil) }

    it "sets the shipment's email_sent_at attribute and saves it" do
      dn.record_sent(shipment)
      expect(shipment.reload.email_sent_at).to be
    end
  end
end
