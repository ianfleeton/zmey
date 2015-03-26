require 'rails_helper'

RSpec.describe NominalCode, type: :model do
  context 'uniqueness' do
    before { FactoryGirl.create(:nominal_code) }
    it { should validate_uniqueness_of(:code) }
  end
end
