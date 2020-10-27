# frozen_string_literal: true

require "rails_helper"

module Formatters
  RSpec.describe Postcode do
    describe "#format" do
      it "uppercases postcodes" do
        expect(Postcode.new("aa9a 9aa").format).to eq "AA9A 9AA"
      end

      it "puts spaces in the correct place" do
        expect(Postcode.new("AA9A9AA").format).to eq "AA9A 9AA"
        expect(Postcode.new("A9A9AA").format).to eq "A9A 9AA"
        expect(Postcode.new("A99AA").format).to eq "A9 9AA"
        expect(Postcode.new("A999AA").format).to eq "A99 9AA"
        expect(Postcode.new("AA99AA").format).to eq "AA9 9AA"
        expect(Postcode.new("AA999AA").format).to eq "AA99 9AA"
      end

      it "recognises Eircode" do
        expect(Postcode.new("T12HN1X").format).to eq "T12 HN1X"
        expect(Postcode.new("D6WHN1X").format).to eq "D6W HN1X"
      end

      it "trims leading and trailing whitespace" do
        expect(Postcode.new(" AA9A 9AA ").format).to eq "AA9A 9AA"
      end

      it "removes spaces from and uppercases unrecognised postcodes" do
        expect(Postcode.new(" banana ").format).to eq "BANANA"
      end
    end

    describe "#district" do
      it "returns the left-hand portion of a UK formatted postcode" do
        expect(Postcode.new(" yo18 1ab ").district).to eq "YO18"
      end
    end
  end
end
