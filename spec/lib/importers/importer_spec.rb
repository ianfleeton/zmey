# frozen_string_literal: true

require "rails_helper"

module Importers
  class FakeModel
    def self.attribute_names
      ["sku"]
    end

    def update(attrs)
    end
  end

  RSpec.describe Importer do
    let(:importer) { Importer.new "Importers::FakeModel" }

    describe "#import" do
      let(:importer) { Importer.new "Product" }

      it "creates new objects" do
        rows = [
          {"sku" => "S1", "name" => "NAME1"},
          {"sku" => "S2", "name" => "NAME2"}
        ]
        importer.import(rows)
        expect(Product.exists?(sku: "S1", name: "NAME1")).to be_truthy
        expect(Product.exists?(sku: "S2", name: "NAME2")).to be_truthy
      end

      it "updates existing objects" do
        product = Product.create!(sku: "S1", name: "original")
        rows = [
          {"sku" => "S1", "name" => "updated"}
        ]
        importer.import(rows)
        expect(product.reload.name).to eq "updated"
      end

      it "skips values of DO-NOT-IMPORT" do
        product = Product.create!(sku: "S1", name: "original")
        rows = [
          {"sku" => "S1", "name" => Importer::DO_NOT_IMPORT}
        ]
        importer.import(rows)
        expect(product.reload.name).to eq "original"
      end
    end

    describe "#error_text" do
      let(:importer) { Importer.new "Product" }

      it "reports on failed creation" do
        rows = [
          {"sku" => "", "name" => "NAME1"}
        ]
        importer.import(rows)

        expect(importer.error_text).to eq(
          '[2] Failed to create: {"sku"=>"", "name"=>"NAME1"}'
        )
      end

      it "joins each message with a newline" do
        rows = [
          {"sku" => "", "name" => "NAME1"},
          {"sku" => "", "name" => "NAME2"}
        ]
        importer.import(rows)

        expect(importer.error_text).to eq(
          '[2] Failed to create: {"sku"=>"", "name"=>"NAME1"}' \
          "\n" \
          '[3] Failed to create: {"sku"=>"", "name"=>"NAME2"}'
        )
      end

      it "reports on failed updates" do
        Product.create!(sku: "S1", name: "original")
        rows = [
          {"sku" => "S1", "name" => ""}
        ]
        importer.import(rows)

        expect(importer.error_text).to eq(
          '[2] Failed to update: {"sku"=>"S1", "name"=>""}'
        )
      end
    end

    describe "#find_object" do
      let(:row) { {"sku" => "CODE"} }

      it "finds an object using the import id" do
        without_partial_double_verification do
          allow(FakeModel).to receive(:import_id).and_return "sku"
          expect(FakeModel).to receive(:find_by).with("sku" => "CODE")
        end
        importer.find_object(row)
      end
    end

    describe "#import_id" do
      context "when class responds to .import_id" do
        before do
          without_partial_double_verification do
            allow(FakeModel).to receive(:import_id).and_return("sku")
          end
        end

        it "returns this value" do
          expect(importer.import_id).to eq "sku"
        end
      end

      context "when the class does not respond to .import_id" do
        it 'returns "id"' do
          expect(importer.import_id).to eq "id"
        end
      end
    end
  end
end
