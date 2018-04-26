require 'rails_helper'

describe BasketMailer do
  let(:website) { FactoryBot.build(:website) }
  let(:basket) { FactoryBot.build(:basket, token: 'xyz') }
  let(:email_address) { 'shopper@example.com' }

  describe 'saved_basket' do
    it 'works' do
      BasketMailer.saved_basket(website, email_address, basket).deliver_now
    end
  end
end
