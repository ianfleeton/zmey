require "rails_helper"

RSpec.describe BackgroundNotifier do
  let(:bn) { BackgroundNotifier.new }

  describe "#send_emails" do
    let(:order) { double(Order) }

    context "for each pending_object" do
      before { allow(bn).to receive(:pending_objects).and_return([order]) }

      it "calls send_email for each pending_object it claims" do
        allow(bn).to receive(:claim).with(order).and_return(true)

        expect(bn).to receive(:send_email).with(order)
        bn.send_emails
      end

      it "skips objects that another run has claimed" do
        allow(bn).to receive(:claim).with(order).and_return(false)

        expect(bn).not_to receive(:send_email)
        bn.send_emails
      end
    end
  end

  describe "#pending_objects" do
    subject { BackgroundNotifier.new.pending_objects }
    it { should eq [] }
  end

  it { should respond_to(:send_email) }
  it { should respond_to(:sent_at_attribute) }
end
