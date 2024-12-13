module PDF
  module ConvertCommands
    class WeasyprintHTMLToPDFCommand < ConvertCommand
      def command
        # It is safe to source the Python venv activation script even if it does not exist.
        "source .python_venv/bin/activate; " \
        "weasyprint #{Shellwords.escape(html_filename)} #{Shellwords.escape(pdf_filename)}"
      end
    end
  end
end
