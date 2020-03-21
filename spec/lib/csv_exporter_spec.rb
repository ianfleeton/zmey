require "rails_helper"

RSpec.describe CSVExporter do
  describe "#filename" do
    let(:exporter) { CSVExporter.new("Product") }

    it "returns a filename based on the time and class" do
      allow(exporter).to receive(:time).and_return(Time.new(2015, 0o5, 0o6, 12, 15))
      expect(exporter.filename).to eq "20150506-1215-Product.csv"
    end
  end

  describe "#record_limit" do
    let(:exporter) { CSVExporter.new("Product") }

    it "returns a number of records" do
      expect(exporter.record_limit).to be_kind_of Integer
    end
  end
end
