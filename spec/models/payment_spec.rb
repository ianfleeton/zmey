require 'rails_helper'

RSpec.describe Payment, type: :model do
  describe 'after_save' do
    let(:order) { FactoryGirl.create(:order) }
    let(:payment) { FactoryGirl.build(:payment, accepted: accepted, order: order) }

    context 'when accepted' do
      let(:accepted) { true }
      it 'notifies its order' do
        expect(order).to receive(:payment_accepted).with(payment)
        payment.save
      end
    end

    context 'when not accepted' do
      let(:accepted) { false }
      it 'does not notify its order' do
        expect(order).not_to receive(:payment_accepted)
        payment.save
      end
    end
  end
end
