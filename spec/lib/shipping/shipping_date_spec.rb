# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe ShippingDate do
    describe "#==" do
      it "equals a ShippingDate whose @date is also a ShippingDate" do
        date = Date.new
        sd1 = ShippingDate.new(date)
        sd2 = ShippingDate.new(sd1)
        expect(sd1).to eq sd2
      end
    end

    describe "#to_s" do
      it "delegates to its date" do
        date = Date.new
        expect(ShippingDate.new(date).to_s).to eq date.to_s
      end
    end

    describe "#to_date" do
      it "returns its date" do
        date = Date.new
        expect(ShippingDate.new(date).to_date).to equal date
      end
    end

    describe "#next_date" do
      it "returns a new ShippingDate" do
        date = Date.new
        original = ShippingDate.new(date)
        next_date = original.next_date
        expect(next_date).to be_instance_of(ShippingDate)
        expect(next_date).not_to equal original
      end

      it "keeps the date checker" do
        date = Date.new
        checker = ProductsDispatchDateChecker.new([])
        sd = ShippingDate.new(date, checker)
        expect(sd.next_date.date_checker).to eq checker
      end
    end

    describe "#possible?" do
      context "without date_checker" do
        it "returns true" do
          expect(ShippingDate.new(Date.new).possible?).to be_truthy
        end
      end
      context "with date_checker" do
        it "returns its date_checker's #possible?" do
          date_checker = double
          date = Date.new
          sd = ShippingDate.new(date, date_checker)
          expect(date_checker).to receive(:possible?).with(date).and_return(false)
          expect(sd.possible?).to be_falsey
        end
      end
    end
  end
end
