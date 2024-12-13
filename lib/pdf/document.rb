# frozen_string_literal: true

require "render_anywhere"
require "shellwords"

module PDF
  # Abstract base class for creating PDF documents that can be generated from
  # HTML templates.
  class Document
    include RenderAnywhere

    attr_reader :header

    def generate
      write_html
      convert_html_to_pdf
    end

    def html
      "<span data-renderer='weasyprint'></span>"
    end

    def renderer
      Nokogiri
        .parse(html)
        .css("[data-renderer]")
        .attribute("data-renderer")
        &.value
        &.to_sym || default_renderer
    end

    # Adds a header to each page using the HTML at the given URL.
    # Returns self to allow chaining.
    def with_header(url)
      @header = url
      self
    end

    # Executes the system command to convert the HTML file to a PDF file.
    def convert_html_to_pdf
      ConvertCommands::ConvertCommand.for(self, testing: Rails.env.test?).execute
    end

    def write_html = File.write(html_filename, html)

    def orientation = "portrait"

    def html_filename = raise "Implement in subclass"

    def pdf_filename = filename

    def filename = raise "Implement in subclass"

    private

    def default_renderer = :weasyprint
  end
end
