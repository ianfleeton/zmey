# frozen_string_literal: true

require "rails_helper"

module Orders
  RSpec.describe DueStatus do
    let(:today) { Date.new(2017, 8, 16) }
    let(:sut) do
      DueStatus.new(website: Website.new(delivery_cutoff_hour: 10), today: today)
    end

    let(:due) do
      {
        delivery_date: today + 1.day,
        dispatch_date: today,
        paid_on: today
      }
    end

    let(:overdue) do
      {
        delivery_date: today,
        dispatch_date: today - 1.day,
        paid_on: today
      }
    end

    describe "#due_orders" do
      it "returns orders that are due" do
        o = FactoryBot.create(:order, due)
        expect(sut.due_orders).to include(o)
      end

      it "does not return overdue orders" do
        o = FactoryBot.create(:order, due.merge(dispatch_date: today - 1.day))
        expect(sut.due_orders).not_to include(o)
      end

      it "does not return shipped orders" do
        o = FactoryBot.create(:order, due.merge(shipped_at: Time.current))
        expect(sut.due_orders).not_to include(o)
      end

      it "does not return orders that are not yet due" do
        o = FactoryBot.create(
          :order, due.merge(dispatch_date: today + 1.days)
        )
        expect(sut.due_orders).not_to include(o)
      end

      it "does not include completed orders" do
        o = FactoryBot.create(:order, due.merge(completed_at: today.to_time))
        expect(sut.due_orders).not_to include(o)
      end

      it "does not include orders updated over 2 months ago" do
        o = FactoryBot.create(:order, due)
        o.update_column(:updated_at, today - 63.days)
        expect(sut.due_orders).not_to include(o)
      end

      it "does not include unpaid orders" do
        o = FactoryBot.create(:order, due.merge(paid_on: nil))
        expect(sut.due_orders).not_to include(o)
      end

      it "it includes unpaid orders if they are on account" do
        o = FactoryBot.create(
          :order,
          due.merge(
            paid_on: nil, status: Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
          )
        )
        expect(sut.due_orders).to include(o)
      end

      it "excludes orders with invalid delivery dates" do
        o = FactoryBot.create(:order, due.merge(dispatch_date: nil))
        ClosureDate.create!(closed_on: o.delivery_date)
        expect(sut.due_orders).not_to include(o)
      end

      it "excludes orders which have collection ready emails" do
        cre = [FactoryBot.create(:collection_ready_email)]
        o = FactoryBot.create(:order, due.merge(collection_ready_emails: cre))
        expect(sut.due_orders).not_to include(o)
      end
    end

    describe "#overdue_orders" do
      it "returns orders that are overdue" do
        o = FactoryBot.create(:order, overdue)
        expect(sut.overdue_orders).to include(o)
      end

      it "does not return due orders" do
        o = FactoryBot.create(
          :order, overdue.merge(dispatch_date: today)
        )
        expect(sut.overdue_orders).not_to include(o)
      end

      it "does not return orders that are not yet due" do
        o = FactoryBot.create(
          :order, overdue.merge(dispatch_date: today + 1.days)
        )
        expect(sut.overdue_orders).not_to include(o)
      end

      it "does not include completed orders" do
        o = FactoryBot.create(
          :order, overdue.merge(completed_at: today.to_time)
        )
        expect(sut.overdue_orders).not_to include(o)
      end

      it "does not include orders updated over 2 months ago" do
        o = FactoryBot.create(:order, overdue)
        o.update_column(:updated_at, today - 63.days)
        expect(sut.overdue_orders).not_to include(o)
      end

      it "does not include unpaid orders" do
        o = FactoryBot.create(:order, overdue.merge(paid_on: nil))
        expect(sut.overdue_orders).not_to include(o)
      end

      it "it includes unpaid orders if they are on account" do
        o = FactoryBot.create(
          :order,
          overdue.merge(
            paid_on: nil, status: Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
          )
        )
        expect(sut.overdue_orders).to include(o)
      end

      it "excludes orders which have collection ready emails" do
        cre = [FactoryBot.create(:collection_ready_email)]
        o = FactoryBot.create(:order, overdue.merge(collection_ready_emails: cre))
        expect(sut.due_orders).not_to include(o)
      end
    end

    describe "#possibly_due" do
      let(:due_status) { DueStatus.new }
      let!(:order) {
        FactoryBot.create(
          :order,
          shipping_method: shipping_method,
          completed_at: nil,
          shipped_at: nil,
          paid_on: Date.yesterday
        )
      }

      context "order is collection, but does not have a collection ready email" do
        let(:shipping_method) { ShippingClass::COLLECTION }

        before do
          order.collection_ready_emails = []
          order.save!
        end

        it "returns the order" do
          expect(due_status.send(:possibly_due)).to include order
        end
      end

      context "order is collection, but has a collection ready email" do
        let(:shipping_method) { ShippingClass::COLLECTION }

        before { order.collection_ready_emails << FactoryBot.create(:collection_ready_email) }

        it "does not return the order" do
          expect(due_status.send(:possibly_due)).not_to include order
        end
      end

      context "order is not a collection, and does not have a collection ready email" do
        let(:shipping_method) { "Mainland" }

        before do
          order.collection_ready_emails = []
          order.save!
        end

        it "returns the order" do
          expect(due_status.send(:possibly_due)).to include order
        end
      end

      context "order is not a collection, and has a collection ready email" do
        let(:shipping_method) { "Mainland" }

        before { order.collection_ready_emails << FactoryBot.create(:collection_ready_email) }

        it "returns the order" do
          expect(due_status.send(:possibly_due)).to include order
        end
      end
    end

    describe "#due_status_for" do
      it "returns :due for a due order" do
        order = FactoryBot.build(:order, due)
        expect(sut.due_status_for(order)).to eq :due
      end

      it "returns :overdue for an overdue order" do
        order = FactoryBot.build(:order, overdue)
        expect(sut.due_status_for(order)).to eq :overdue
      end
    end

    describe "#due_status_class" do
      subject { sut.due_status_class(order) }

      let(:order) do
        instance_double(
          Order,
          relevant_delivery_date: Date.today,
          dispatch_date: nil,
          lead_time: 0,
          order_lines: [],
          shipping_method: ""
        )
      end

      before do
        allow(sut).to receive(:due_status?).and_return(due_status?)
        allow(sut).to receive(:due_status).and_return(due_status)
      end

      context "when order has no due status" do
        let(:due_status?) { false }
        let(:due_status) { :due }
        it { should be_nil }
      end

      context "when order has due status" do
        let(:due_status?) { true }

        context "when status is :none" do
          let(:due_status) { :none }
          it { should be_nil }
        end

        context "when status is :overdue" do
          let(:due_status) { :overdue }
          it { should eq "order-danger" }
        end

        context "when status is :due" do
          let(:due_status) { :due }
          it { should eq "order-warning" }
        end

        context "when status is :not_yet_due" do
          let(:due_status) { :not_yet_due }
          it { should eq "order-success" }
        end

        context "when status is :upcoming" do
          let(:due_status) { :upcoming }
          it { should eq "order-success" }
        end
      end
    end

    describe "#due_status?" do
      subject { sut.due_status?(order) }

      let(:order) do
        instance_double(
          Order,
          shippable?: shippable?,
          collectable?: collectable?,
          shipped_at: shipped_at,
          relevant_delivery_date: relevant_delivery_date,
          collection_ready_emails: collection_ready_emails
        )
      end
      let(:shippable?) { true }
      let(:collectable?) { false }
      let(:shipped_at) { nil }
      let(:relevant_delivery_date) { Date.today }
      let(:collection_ready_emails) { [] }

      context "when order is shippable yet not fully shipped and has a " \
      "relevant delivery date" do
        it { should be_truthy }
      end

      context "when order is collectable, not fully shipped and has a " \
      "relevant delivery date" do
        let(:shippable?) { false }
        let(:collectable?) { true }
        it { should be_truthy }
      end

      context "when order is not shippable or collectable?" do
        let(:shippable?) { false }
        let(:collectable?) { false }
        it { should be_falsey }
      end

      context "when order has been shipped" do
        let(:shipped_at) { Date.current }
        it { should be_falsey }
      end

      context "when order has no relevant delivery date" do
        let(:relevant_delivery_date) { nil }
        it { should be_falsey }
      end

      context "when order has collection ready emails" do
        let(:collection_ready_emails) { [FactoryBot.build(:collection_ready_email)] }
        it { should be_falsey }
      end
    end

    describe "#due_status" do
      subject { sut.due_status(date) }

      context "when due date is nil" do
        let(:date) { nil }
        it { should eq :none }
      end

      context "when due date is today" do
        let(:date) { today }
        it { should eq :due }
      end

      context "when due date is in the past" do
        let(:date) { today - 1.day }
        it { should eq :overdue }
      end

      context "when due date is tomorrow" do
        let(:date) { today + 1.day }
        it { should eq :upcoming }
      end

      context "when due date is day after tomorrow" do
        let(:date) { today + 2.days }
        it { should eq :not_yet_due }
      end

      context "when day is Friday and due date is Monday" do
        let(:today) { Date.new(2017, 8, 18) }
        let(:date) { Date.new(2017, 8, 21) }
        it { should eq :upcoming }
      end

      context "when day is Saturday and due date is Monday" do
        let(:today) { Date.new(2017, 8, 19) }
        let(:date) { Date.new(2017, 8, 21) }
        it { should eq :upcoming }
      end
    end

    describe "#departments" do
      it "returns an empty array for an empty order" do
        o = FactoryBot.create(:order)
        expect(sut.departments(o)).to eq []
      end

      it "returns an empty array when products not in groups" do
        o = FactoryBot.create(:order)
        FactoryBot.create(:order_line, order: o)

        expect(sut.departments(o)).to eq []
      end

      it "includes unique, sorted locations for products in the order" do
        computers = FactoryBot.create(:location, name: "Computers")
        books = FactoryBot.create(:location, name: "Books")
        pg1 = FactoryBot.create(:product_group, location: computers)
        pg2 = FactoryBot.create(:product_group, location: books)
        p1 = FactoryBot.create(:product, product_groups: [pg1])
        p2 = FactoryBot.create(:product, product_groups: [pg2])
        p3 = FactoryBot.create(:product, product_groups: [pg1, pg2])
        o = FactoryBot.create(:order)
        FactoryBot.create(:order_line, order: o, product: p1)
        FactoryBot.create(:order_line, order: o, product: p2)
        FactoryBot.create(:order_line, order: o, product: p3)

        expect(sut.departments(o)).to eq %w[Books Computers]
      end
    end

    describe "#departments_summary" do
      it "returns counts or departments appearing in orders" do
        computers = FactoryBot.create(:location, name: "Computers")
        books = FactoryBot.create(:location, name: "Books")
        pg1 = FactoryBot.create(:product_group, location: computers)
        pg2 = FactoryBot.create(:product_group, location: books)
        p1 = FactoryBot.create(:product, product_groups: [pg1])
        p2 = FactoryBot.create(:product, product_groups: [pg2])
        o1 = FactoryBot.create(:order)
        FactoryBot.create(:order_line, order: o1, product: p1)
        o2 = FactoryBot.create(:order)
        FactoryBot.create(:order_line, order: o2, product: p2)
        o3 = FactoryBot.create(:order)
        FactoryBot.create(:order_line, order: o3, product: p2)

        expect(sut.departments_summary([o1, o2, o3])).to eq(
          "Computers" => 1, "Books" => 2
        )
      end
    end
  end
end
