require 'rails_helper'

RSpec.describe OfflinePaymentMethod, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  describe '#to_s' do
    it 'returns name' do
      expect(OfflinePaymentMethod.new(name: 'Chip & PIN').to_s).to eq 'Chip & PIN'
    end
  end
end
