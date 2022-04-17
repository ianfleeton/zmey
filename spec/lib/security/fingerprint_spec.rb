# frozen_string_literal: true

require "rails_helper"

module Security
  RSpec.describe Fingerprint do
    let(:precalculated_hash) { Digest::MD5.hexdigest("a--b--c").freeze }

    let(:object) { OpenStruct.new(a: "a", b: "b", c: "c", d: "d") }
    let(:attributes) { [:a, :b, :c] }
    let(:fingerprint) { Fingerprint.new(object, attributes) }

    describe "#to_s" do
      subject { fingerprint.to_s }
      it { should eq precalculated_hash }
    end

    describe "#hash" do
      subject { fingerprint.hash }
      it { should eq precalculated_hash }
    end

    describe "#==" do
      it "is equal to itself" do
        # rubocop:disable Lint/BinaryOperatorWithIdenticalOperands
        expect(fingerprint == fingerprint).to be_truthy
        # rubocop:enable Lint/BinaryOperatorWithIdenticalOperands
      end

      it "is equal to a fingerprint of the same object and attributes" do
        expect(fingerprint == Fingerprint.new(object, attributes)).to be_truthy
      end

      it "is equal to its hash string" do
        expect(fingerprint == precalculated_hash).to be_truthy
      end

      it "is not equal to a different hash string" do
        expect(fingerprint == ("a" * 32)).to be_falsey
      end

      it "is not equal to a fingerprint of object with different attributes" do
        other_obj = OpenStruct.new(a: "z", b: "y", c: "x", d: "d")
        other = Fingerprint.new(other_obj, attributes)
        expect(fingerprint == other).to be_falsey
      end
    end
  end
end
