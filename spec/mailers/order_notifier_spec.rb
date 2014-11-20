require 'rails_helper'

describe OrderNotifier do
  let(:website) { FactoryGirl.build(:website) }
  let(:order) { FactoryGirl.build(:order) }

  describe 'notification' do
    it 'works' do
      OrderNotifier.notification(website, order).deliver_now
    end
  end

  describe 'admin_waiting_for_payment' do
    it 'works' do
      OrderNotifier.admin_waiting_for_payment(website, order).deliver_now
    end
  end
end
