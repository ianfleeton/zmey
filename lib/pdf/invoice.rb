require "render_anywhere"

module PDF
  class Invoice
    include RenderAnywhere

    def initialize(order)
      @order = order
    end

    def generate
      write_html
      convert_html_to_pdf
    end

    def write_html
      File.open(html_filename, "w") { |f| f.write(html) }
    end

    def convert_html_to_pdf
      `#{WebKitHTMLToPDF.binary} #{html_filename} #{filename}`
    end

    def html
      set_instance_variable(:order, @order)
      render template, layout: layout
    end

    class RenderingController < ApplicationController
      def initialize
        super
        set_resolver
      end
      attr_accessor :order
    end

    def template
      "orders/invoice"
    end

    def layout
      "layouts/invoice"
    end

    def html_filename
      "tmp/invoice.html"
    end

    def filename
      "tmp/invoice.pdf"
    end
  end
end
