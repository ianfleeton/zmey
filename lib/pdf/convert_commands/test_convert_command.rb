module PDF
  module ConvertCommands
    class TestConvertCommand < ConvertCommand
      def command
        raise "Ensure #{html_filename} exists to suppress test output to stdout" unless File.exist?(html_filename)
        "cp #{Shellwords.escape(html_filename)} #{Shellwords.escape(pdf_filename)}"
      end
    end
  end
end
