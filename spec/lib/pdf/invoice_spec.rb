require 'rails_helper'

module PDF
  RSpec.describe Invoice do
    before { FactoryBot.create(:website) }

    let(:order) { FactoryBot.create(:order) }
    let(:invoice) { Invoice.new(order) }

    describe '#generate' do
      it 'works' do
        invoice.generate
      end
    end

    describe '#html' do
      subject { invoice.html }
      it { should include(order.order_number) }
    end
  end
end
