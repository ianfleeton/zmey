module PDF
  module ConvertCommands
    class ConvertCommand
      attr_reader :document
      delegate :header, :html_filename, :orientation, :pdf_filename, to: :document

      def self.for(document, testing:)
        if testing
          TestConvertCommand
        else
          command_for_renderer(document.renderer)
        end.new(document)
      end

      def self.command_for_renderer(renderer)
        case renderer
        when :weasyprint
          WeasyprintHTMLToPDFCommand
        else
          raise "Unknown renderer: #{renderer}"
        end
      end

      def initialize(document) = @document = document

      def execute
        remove_previous_pdf
        Rails.logger.info("Converting HTML to PDF")
        Rails.logger.info(command)
        `#{command}`
        Rails.logger.info("Converted HTML to PDF")
      end

      def command
        "echo Implement in subclass"
      end

      private

      # Prevent susbequent errors in PDF generation from being masked by using a previously
      # generated PDF.
      def remove_previous_pdf
        Rails.logger.info("Removing previous version of #{pdf_filename} (if any)")
        File.delete(pdf_filename) if File.exist?(pdf_filename)
      end
    end
  end
end
