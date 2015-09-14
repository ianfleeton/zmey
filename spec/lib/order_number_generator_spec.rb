require 'rails_helper'

RSpec.describe OrderNumberGenerator do
  describe '.get_generator' do
    subject { OrderNumberGenerator.get_generator(Order.new) }
    it { should be_kind_of(OrderNumberGenerator::Base) }
  end
end
