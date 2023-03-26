# frozen_string_literal: true

require "rails_helper"

module Shipping
  RSpec.describe DispatchDate do
    describe "#possible?" do
      context "with date_checker" do
        it "returns its date_checker's #possible?" do
          date_checker = double
          date = Date.new
          dd = DispatchDate.new(date, date_checker)
          expect(dd).to receive(:possible_with_closures?).and_return(true)
          expect(date_checker).to receive(:possible?).with(date).and_return(false)
          expect(dd.possible?).to be_falsey
        end
      end
    end
  end
end
