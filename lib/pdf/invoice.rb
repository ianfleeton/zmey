module PDF
  class Invoice < OrderDocument
    def template
      "orders/invoice"
    end

    def layout
      "layouts/invoice"
    end

    def html_filename
      "tmp/invoice.#{@order.order_number}.html"
    end

    def filename
      "tmp/Order #{@order.order_number} - #{@order.paperwork_type.titleize}.pdf"
    end
  end
end
