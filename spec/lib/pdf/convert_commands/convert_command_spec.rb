require "rails_helper"

module PDF
  module ConvertCommands
    class TestDocument < Document
      def filename = @filename ||= Rails.root.join("tmp", "document.#{SecureRandom.hex}.pdf")
    end

    class TestWeasyprintDocument < TestDocument
      def renderer = :weasyprint
    end

    class UnknownRendererDocument < TestDocument
      def renderer = :unknown
    end

    RSpec.describe ConvertCommand do
      describe ".for" do
        it "returns a WeasyprintHTMLToPDFCommand for the WeasyPrint renderer" do
          document = TestWeasyprintDocument.new
          command = ConvertCommand.for(document, testing: false)

          expect(command).to be_a(WeasyprintHTMLToPDFCommand)
        end

        it "raises an error for an unknown renderer" do
          document = UnknownRendererDocument.new
          expect { ConvertCommand.for(document, testing: false) }.to raise_error "Unknown renderer: unknown"
        end

        it "returns a TestConvertCommand for testing" do
          document = TestWeasyprintDocument.new
          command = ConvertCommand.for(document, testing: true)

          expect(command).to be_a(TestConvertCommand)
        end
      end

      describe "#execute" do
        it "records the correct logger messages" do
          command = ConvertCommand.new(TestDocument.new)

          allow(Rails.logger).to receive(:info)
          expect(Rails.logger).to receive(:info).with("Converting HTML to PDF")
          expect(Rails.logger).to receive(:info).with("echo Implement in subclass")
          expect(Rails.logger).to receive(:info).with("Converted HTML to PDF")

          command.execute
        end

        it "removes a previously generated PDF file if found" do
          document = TestDocument.new
          command = ConvertCommand.new(document)
          File.write(document.pdf_filename, "stale")

          command.execute

          expect(File.exist?(document.pdf_filename)).to be_falsey
        end
      end
    end
  end
end
