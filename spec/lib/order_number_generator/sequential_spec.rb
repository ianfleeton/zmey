require 'rails_helper'

module OrderNumberGenerator
  RSpec.describe Sequential do
    describe '.generate' do
      let(:order) { FactoryGirl.build(:order) }
      subject { Sequential.new(order).generate }
      context 'no other orders' do
        it { should eq '1' }
      end

      context 'highest order number 1234' do
        before { FactoryGirl.create(:order, order_number: '1234') }
        it { should eq '1235' }
      end
    end
  end
end
