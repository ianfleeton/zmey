# frozen_string_literal: true

require "rails_helper"

module Orders
  RSpec.describe Recycler do
    describe ".new_or_recycled" do
      subject { Recycler.new_or_recycled(id) }

      context "when order_id nil" do
        let(:id) { nil }
        it { should be_instance_of(Order) }
        it "is new" do
          expect(subject.new_record?).to eq true
        end
      end

      context "when order exists" do
        let(:paid_on) { nil }
        let(:order) do
          FactoryBot.create(:order, :unpaid, status:, paid_on:)
        end

        let(:id) { order.id }

        context "when status is waiting for payment" do
          let(:status) { Enums::PaymentStatus::WAITING_FOR_PAYMENT }
          it { should eq order }

          context "with order lines" do
            before do
              FactoryBot.create(:order_line, order: order)
            end
            it "deletes order lines" do
              expect(subject.order_lines.count).to eq 0
            end
          end

          context "when order has been paid and later refunded" do
            let(:paid_on) { Date.current }
            it "is new" do
              expect(subject.new_record?).to eq true
            end
          end
        end

        context "when status is not waiting for payment" do
          let(:status) { Enums::PaymentStatus::QUOTE }
          it { should be_instance_of(Order) }
          it "is new" do
            expect(subject.new_record?).to eq true
          end
        end
      end

      context "when order does not exist" do
        let(:id) { 123 }
        it { should be_instance_of(Order) }
        it "is new" do
          expect(subject.new_record?).to eq true
        end
      end
    end
  end
end
