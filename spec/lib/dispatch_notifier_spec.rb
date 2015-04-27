require 'rails_helper'

RSpec.describe DispatchNotifier do
  let(:dn) { DispatchNotifier.new }

  describe '#pending_objects' do
    let(:pending) { FactoryGirl.create(:order, shipped_at: Date.today, shipment_email_sent_at: nil) }
    let(:already_sent) { FactoryGirl.create(:order, shipped_at: Date.today, shipment_email_sent_at: Date.today) }
    let(:unshipped) { FactoryGirl.create(:order, shipped_at: nil) }

    it 'returns only orders pending dispatch notifications' do
      orders = dn.pending_objects
      expect(orders).to include(pending)
      expect(orders).not_to include(already_sent)
      expect(orders).not_to include(unshipped)
    end
  end

  describe '#send_email' do
    before { FactoryGirl.create(:website) }
    let(:order) { FactoryGirl.create(:order) }

    it 'sends a dispatch notification email' do
      expect { dn.send_email(order) }
        .to change { ActionMailer::Base.deliveries.count }
        .by(1)
    end
  end

  describe '#record_sent' do
    let(:order) { FactoryGirl.create(:order, shipment_email_sent_at: nil) }

    it "sets the order's shipment_email_sent_at attribute and saves it" do
      dn.record_sent(order)
      expect(order.reload.shipment_email_sent_at).to be
    end
  end
end
