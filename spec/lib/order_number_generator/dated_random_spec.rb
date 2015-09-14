require 'rails_helper'

module OrderNumberGenerator
  RSpec.describe DatedRandom do
    describe '.generate' do
      let(:order) { FactoryGirl.create(:order) }
      subject { DatedRandom.new(order).generate }
      it 'generates a 13 character string' do
        expect(subject.length).to eq 13
      end
    end
  end
end
