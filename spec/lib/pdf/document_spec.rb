# frozen_string_literal: true

require "rails_helper"

module PDF
  class TestDocument < Document
    def html_filename
      "tmp/testfile.html"
    end

    def filename
      "tmp/testfile.pdf"
    end
  end

  RSpec.describe Document do
    describe "#renderer" do
      let(:document) { TestDocument.new }

      it "returns the renderer from the default HTML" do
        expect(document.renderer).to eq(:weasyprint)
      end

      context "overridden HTML contains a renderer" do
        before { def document.html = "<span data-renderer='cat'></span>" }

        it "returns the renderer from the overridden HTML" do
          expect(document.renderer).to eq(:cat)
        end
      end

      context "overridden HTML does not contain a renderer" do
        before { def document.html = "<span></span>" }

        it "returns the default renderer" do
          expect(document.renderer).to eq(:weasyprint)
        end
      end
    end

    describe "#with_header" do
      let(:document) { TestDocument.new }

      it "sets the header attribute" do
        doc = document.with_header("https://header.url")
        expect(doc.header).to eq "https://header.url"
      end
    end

    describe "#convert_html_to_pdf" do
      let(:document) { TestDocument.new }

      it "executes a conversion command" do
        command = instance_double(ConvertCommands::ConvertCommand)
        expect(ConvertCommands::ConvertCommand)
          .to receive(:for)
          .and_return(command)
        expect(command).to receive(:execute)
        document.convert_html_to_pdf
      end
    end
  end
end
