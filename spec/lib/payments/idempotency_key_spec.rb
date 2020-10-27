require "rails_helper"

module Payments
  RSpec.describe IdempotencyKey do
    describe "#to_s" do
      it "returns a key 16 characters long" do
        expect(IdempotencyKey.new.to_s.length).to eq 16
      end

      it "returns the same key when called again for the same object" do
        key = IdempotencyKey.new
        expect(key.to_s).to eq key.to_s
      end

      it "returns different keys for different objects" do
        expect(IdempotencyKey.new.to_s).not_to eq(IdempotencyKey.new.to_s)
      end
    end
  end
end
