# frozen_string_literal: true

module PDF
  class OrderConfirmationInfo < Document
    def html
      set_instance_variable(:website, Website.first)
      render "pdfs/order_confirmation_info", layout: "layouts/invoice"
    end

    def html_filename
      "tmp/OrderConfirmationInfo.html"
    end

    def filename
      "tmp/OrderConfirmationInfo.pdf"
    end

    class RenderingController < ApplicationController
      def initialize
        super
      end

      # Provide a request object that returns nil for any attributes.
      def request
        OpenStruct.new
      end
    end
  end
end
