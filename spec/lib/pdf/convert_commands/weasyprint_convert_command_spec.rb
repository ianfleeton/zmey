require "rails_helper"

module PDF
  module ConvertCommands
    class TestDocument < Document
      def html_filename
        "tmp/testfile.html"
      end

      def filename
        "tmp/testfile.pdf"
      end
    end

    RSpec.describe WeasyprintHTMLToPDFCommand do
      describe "#command" do
        it "returns the weasyprint command to generate a PDF" do
          command = WeasyprintHTMLToPDFCommand.new(TestDocument.new)
          expect(command.command).to eq "source .python_venv/bin/activate; weasyprint tmp/testfile.html tmp/testfile.pdf"
        end
      end
    end
  end
end
