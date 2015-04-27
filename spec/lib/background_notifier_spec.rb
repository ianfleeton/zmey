require 'rails_helper'

RSpec.describe BackgroundNotifier do
  let(:bn) { BackgroundNotifier.new }

  describe '#send_emails' do
    let(:order) { double(Order) }

    context 'for each pending_object' do
      before { allow(bn).to receive(:pending_objects).and_return([order]) }

      it 'calls send_email for each pending_object' do
        allow(bn).to receive(:record_sent)

        expect(bn).to receive(:send_email).with(order)
        bn.send_emails
      end

      it 'calls record_sent for each pending_object' do
        allow(bn).to receive(:send_email)

        expect(bn).to receive(:record_sent).with(order)
        bn.send_emails
      end
    end
  end

  describe '#pending_objects' do
    subject { BackgroundNotifier.new.pending_objects }
    it { should eq [] }
  end

  it { should respond_to(:send_email) }
  it { should respond_to(:record_sent) }
end
