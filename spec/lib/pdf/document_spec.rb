# frozen_string_literal: true

require "rails_helper"

module PDF
  class TestDocument < Document
    def html_filename
      "testfile.html"
    end

    def filename
      "testfile.pdf"
    end
  end

  RSpec.describe Document do
    describe "#with_header" do
      it "sets the header attribute" do
        doc = TestDocument.new.with_header("https://header.url")
        expect(doc.header).to eq "https://header.url"
      end

      it "adds a header argument to the command" do
        cmd = TestDocument.new.with_header("https://header.url")
          .convert_html_to_pdf_command
        expect(cmd).to include("--header-html https://header.url")
      end

      it "includes no header argment in command when passed nil" do
        cmd = TestDocument.new.with_header(nil).convert_html_to_pdf_command
        expect(cmd).not_to include("--header-html")
      end
    end
  end
end
