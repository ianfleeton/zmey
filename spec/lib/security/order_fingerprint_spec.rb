# frozen_string_literal: true

require "rails_helper"

module Security
  RSpec.describe OrderFingerprint do
    describe "delegations" do
      subject { OrderFingerprint.new(Order.new) }
      it { should delegate_method(:hash).to(:fingerprint) }
      it { should delegate_method(:to_s).to(:fingerprint) }

      describe "#==" do
        it "delegates to Fingerprint" do
          fp = instance_double(Fingerprint)
          expect(Fingerprint).to receive(:new).and_return(fp)
          result = [true, false].sample
          expect(fp).to receive(:==).and_return(result)
          expect(subject == "xyz").to eq result
        end
      end
    end
  end
end
