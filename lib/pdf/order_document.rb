module PDF
  class OrderDocument < Document
    def initialize(order)
      @order = order
    end

    def html
      set_instance_variable(:order, @order)
      render template, layout: layout
    end

    class RenderingController < ApplicationController
      def initialize
        super
        website
      end

      # Provide a request object that returns nil for any attributes.
      def request
        OpenStruct.new
      end

      attr_accessor :order
    end
  end
end
