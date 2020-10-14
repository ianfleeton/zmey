require "rails_helper"

RSpec.describe CollectionReadyEmail, type: :model do
  describe "associations" do
    it { should belong_to(:order) }
  end

  describe ".applicable?" do
    subject { CollectionReadyEmail.applicable? order }

    context "when the order is not collectable" do
      let(:order) do
        instance_double(Order, collectable?: false, collection_ready_emails: [])
      end
      it { should be_falsey }
    end

    context "when the order has collection ready emails" do
      let(:order) do
        instance_double(
          Order,
          collectable?: true,
          collection_ready_emails: [CollectionReadyEmail.new]
        )
      end
      it { should be_falsey }
    end

    context "when the order is collectable and has no collection ready " \
    "emails" do
      let(:order) do
        instance_double(Order, collectable?: true, collection_ready_emails: [])
      end
      it { should be_truthy }
    end
  end

  describe ".enqueue" do
    it "creates a new CollectionReadyEmail" do
      order = instance_double(Order)
      expect(CollectionReadyEmail)
        .to receive(:create!)
        .with(order: order)
      CollectionReadyEmail.enqueue(order)
    end
  end
end
