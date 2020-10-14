# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe DispatchDeliveryDate do
    describe "#to_s" do
      it "returns a string including both dates" do
        ddd = DispatchDeliveryDate.new(
          Date.new(2017, 7, 12), Date.new(2017, 7, 13)
        )
        expect(ddd.to_s).to eq "Dispatch: 2017-07-12, Delivery: 2017-07-13"
      end
    end

    describe "#==" do
      it "returns truthy if both dates match" do
        ddd1 = DispatchDeliveryDate.new(
          Date.new(2017, 7, 12), Date.new(2017, 7, 13)
        )
        ddd2 = DispatchDeliveryDate.new(
          Date.new(2017, 7, 12), Date.new(2017, 7, 13)
        )
        expect(ddd1).to eq ddd2
      end

      it "returns falsey if either date does not match" do
        ddd1 = DispatchDeliveryDate.new(
          Date.new(2017, 7, 13), Date.new(2017, 7, 13)
        )
        ddd2 = DispatchDeliveryDate.new(
          Date.new(2017, 7, 12), Date.new(2017, 7, 13)
        )
        expect(ddd1).not_to eq ddd2
      end
    end

    describe ".list" do
      let(:num) { 1 }
      let(:lead) { 0 }
      let(:delivery) { 1 }
      let(:cutoff) { 10 }
      let(:start) { Time.current }
      let(:dispatch_date_checker) { nil }
      let(:spec) do
        DispatchDeliverySpec.new(
          start: start, lead: lead, delivery: delivery, cutoff: cutoff,
          num: num, items: [], dispatch_date_checker: dispatch_date_checker
        )
      end

      describe "with num set higher" do
        let(:num) { 3 }
        it "returns num dates" do
          expect(DispatchDeliveryDate.list(spec).count).to eq 3
        end
      end

      describe "first item" do
        subject { DispatchDeliveryDate.list(spec).first }

        context "with zero lead time, 1 day delivery, before cutoff hour" do
          let(:lead) { 0 }
          let(:cutoff) { 12 }

          context "on Monday" do
            let(:start) { Time.new(2017, 7, 3, 11, 0) }

            it "returns Monday for dispatch date" do
              expect(subject.dispatch_date).to eq Date.new(2017, 7, 3)
            end

            it "returns Tuesday for delivery date" do
              expect(subject.delivery_date).to eq Date.new(2017, 7, 4)
            end

            context "when Monday is closed for delivery & dispatch" do
              let!(:bank_holiday) do
                ClosureDate.create!(closed_on: Date.new(2017, 7, 3))
              end

              it "returns Tuesday for dispatch date" do
                expect(subject.dispatch_date).to eq Date.new(2017, 7, 4)
              end

              it "returns Wednesday for delivery date" do
                expect(subject.delivery_date).to eq Date.new(2017, 7, 5)
              end
            end

            context "when Tuesday is closed for dispatch only" do
              let!(:no_dispatch_day) do
                ClosureDate.create!(
                  closed_on: Date.new(2017, 7, 4), delivery_possible: true
                )
              end

              it "returns Monday for dispatch date" do
                expect(subject.dispatch_date).to eq Date.new(2017, 7, 3)
              end

              it "returns Tuesday for delivery date" do
                expect(subject.delivery_date).to eq Date.new(2017, 7, 4)
              end
            end
          end

          context "on Friday" do
            let(:start) { Time.new(2017, 7, 7, 11, 0) }

            it "returns Friday for dispatch date" do
              expect(subject.dispatch_date)
                .to eq DispatchDate.new(Date.new(2017, 7, 7))
            end

            it "returns Monday for delivery date" do
              expect(subject.delivery_date)
                .to eq DeliveryDate.new(Date.new(2017, 7, 10))
            end

            context "with a bank holiday Monday" do
              let!(:bank_holiday) do
                ClosureDate.create!(closed_on: Date.new(2017, 7, 10))
              end

              it "returns Tuesday for delivery date" do
                expect(subject.delivery_date).to eq Date.new(2017, 7, 11)
              end
            end
          end

          context "on Saturday" do
            let(:start) { Time.new(2017, 7, 8, 11, 0) }

            it "returns Monday for dispatch date" do
              expect(subject.dispatch_date).to eq Date.new(2017, 7, 10)
            end

            it "returns Tuesday for delivery date" do
              expect(subject.delivery_date).to eq Date.new(2017, 7, 11)
            end
          end
        end

        context "with 1 day lead time, 1 day delivery, before cutoff hour" do
          let(:lead) { 1 }
          let(:cutoff) { 12 }

          context "on Monday" do
            let(:start) { Time.new(2017, 7, 3, 11, 0) }

            it "returns Tuesaday for dispatch date" do
              expect(subject.dispatch_date).to eq Date.new(2017, 7, 4)
            end

            it "returns Wednesday for delivery date" do
              expect(subject.delivery_date).to eq Date.new(2017, 7, 5)
            end

            context "with a dispatch date checker impossible on Tuesday" do
              let(:dispatch_date_checker) { instance_double(ProductsDispatchDateChecker) }
              before do
                expect(dispatch_date_checker).to receive(:possible?)
                  .with(Date.new(2017, 7, 4)).and_return(false)
                expect(dispatch_date_checker).to receive(:possible?)
                  .with(Date.new(2017, 7, 5)).and_return(true)
                expect(dispatch_date_checker).to receive(:possible?)
                  .with(Date.new(2017, 7, 6)).and_return(true)
              end

              it "returns Wednesday for dispatch date" do
                expect(subject.dispatch_date).to eq Date.new(2017, 7, 5)
              end
            end

            context "with a dispatch date checker impossible on Monday" do
              let(:dispatch_date_checker) { instance_double(ProductsDispatchDateChecker) }
              before do
                expect(dispatch_date_checker).to receive(:possible?)
                  .with(Date.new(2017, 7, 4)).and_return(true)
                expect(dispatch_date_checker).to receive(:possible?)
                  .with(Date.new(2017, 7, 5)).and_return(true)
              end

              it "returns Tuesday for dispatch date (it does not start " \
              "excluding dates before lead time + cut off are accounted for)" do
                expect(subject.dispatch_date).to eq Date.new(2017, 7, 4)
              end
            end
          end
        end

        context "with zero lead time, 1 day delivery, after cutoff hour" do
          let(:lead) { 0 }
          let(:cutoff) { 12 }

          context "on Sunday" do
            let(:start) { Time.new(2017, 7, 2, 12, 15) }

            it "returns Monday for dispatch date" do
              expect(subject.dispatch_date).to eq Date.new(2017, 7, 3)
            end
          end

          context "on Monday" do
            let(:start) { Time.new(2017, 7, 3, 12, 15) }

            it "returns Tuesday for dispatch date" do
              expect(subject.dispatch_date).to eq Date.new(2017, 7, 4)
            end

            it "returns Wednesday for delivery date" do
              expect(subject.delivery_date).to eq Date.new(2017, 7, 5)
            end
          end
        end

        context "with zero lead time, zero day delivery, before cutoff hour" do
          let(:lead) { 0 }
          let(:cutoff) { 12 }
          let(:delivery) { 0 }

          context "on Monday" do
            let(:start) { Time.new(2017, 7, 3, 11, 0) }

            it "returns Monday for dispatch date" do
              expect(subject.dispatch_date).to eq Date.new(2017, 7, 3)
            end

            it "returns Monday for delivery date" do
              expect(subject.delivery_date).to eq Date.new(2017, 7, 3)
            end
          end
        end
      end
    end

    describe ".delivery_dates" do
      it "returns an array of delivery dates" do
        spec = DispatchDeliverySpec.new(
          start: Time.new(2017, 7, 3, 11, 0),
          lead: 0, delivery: 1, cutoff: 12, num: 1, items: []
        )
        dates = DispatchDeliveryDate.delivery_dates(spec)
        expect(dates[0]).to eq Date.new(2017, 7, 4)
      end
    end

    describe ".dispatch_date" do
      it "returns the dispatch date for a given delivery date" do
        spec = DispatchDeliverySpec.new(
          start: Time.new(2017, 7, 3, 11, 0),
          lead: 0, delivery: 1, cutoff: 12, num: 1, items: []
        )
        delivery_date = Date.new(2017, 7, 4)
        expect(DispatchDeliveryDate.dispatch_date(spec, delivery_date))
          .to eq Date.new(2017, 7, 3)
      end

      it "returns nil if no valid date found" do
        spec = DispatchDeliverySpec.new(
          start: Time.new(2017, 7, 3, 11, 0),
          lead: 0, delivery: 1, cutoff: 12, num: 1, items: []
        )
        delivery_date = Date.new(2016, 7, 4)
        expect(DispatchDeliveryDate.dispatch_date(spec, delivery_date))
          .to be_nil
      end
    end
  end
end
