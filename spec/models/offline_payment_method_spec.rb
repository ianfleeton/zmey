require 'rails_helper'

RSpec.describe OfflinePaymentMethod, type: :model do
  describe 'validations' do
    subject { FactoryBot.build(:offline_payment_method) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe '#to_s' do
    it 'returns name' do
      expect(OfflinePaymentMethod.new(name: 'Chip & PIN').to_s).to eq 'Chip & PIN'
    end
  end
end
