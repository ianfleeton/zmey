# frozen_string_literal: true

require "render_anywhere"
require "shellwords"

module PDF
  # Abstract base class for creating PDF documents that can be generated from
  # HTML templates.
  class Document
    include RenderAnywhere

    attr_reader :header

    def initialize
      @header = nil
    end

    def generate
      write_html
      convert_html_to_pdf
    end

    # Adds a header to each page using the HTML at the given URL.
    # Returns self to allow chaining.
    def with_header(url)
      @header = url
      self
    end

    # The system command used to convert the HTML file to a PDF file.
    def convert_html_to_pdf_command
      "#{WebKitHTMLToPDF.binary} -O #{orientation} #{header_command} " \
        "--disable-smart-shrinking " \
        "-T 15mm -B 25mm -L 10mm -R 10mm " \
        "#{Shellwords.escape(html_filename)} " \
        "#{Shellwords.escape(filename)} 2>/dev/null"
    end

    # Executes the system command to convert the HTML file to a PDF file.
    def convert_html_to_pdf
      cmd = convert_html_to_pdf_command
      Rails.logger.info("Converting HTML to PDF")
      Rails.logger.info(cmd)
      `#{cmd}`
      Rails.logger.info("Converted HTML to PDF")
    end

    def write_html
      File.open(html_filename, "w") { |f| f.write(html) }
    end

    def orientation
      "portrait"
    end

    private

    def header_command
      "--header-html #{Shellwords.escape(header)}" if header
    end
  end
end
