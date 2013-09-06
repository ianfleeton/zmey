class Invoice
  include ActionView::Helpers::NumberHelper
  include ProductsHelper

  def initialize(opts)
    @order = opts[:order]
    @invoice_details = opts[:invoice_details]
  end

  def generate
    FileUtils.makedirs(dir)

    Prawn::Document.generate(filename, page_size: 'A4') do |pdf|
      spacing = 3
      pdf.font 'fonts/MuseoSans_500.otf'
      pdf.font_size 18
      pdf.text "Invoice number #{@order.order_number}"
      pdf.move_down 24
      pdf.font_size 11
      pdf.text "Invoice created at: #{@order.created_at}"
      pdf.move_down 24

      address_top = 700

      if @invoice_details
        pdf.bounding_box([0, address_top], width: 200, height: 200) do
          pdf.text @invoice_details, leading: 4
        end
      end

      pdf.bounding_box([300, address_top], width: 200, height: 200) do
        pdf.text("Customer:\n" + @order.full_name + "\n" +
          @order.address_line_1 + "\n" + @order.address_line_2 + "\n" +
          @order.town_city + "\n" + @order.county + "\n" + @order.postcode +
          "\n" + @order.country.to_s, leading: 4)
      end

      cells = []
      cells << ["Product", "Price"]
      @order.order_lines.each do |line|
        product = line.product_name
        product += " - " + line.feature_descriptions unless line.feature_descriptions.empty?
        cells << [product, formatted_gbp_price(line.line_total)]
      end
      cells << ["Order total:", formatted_gbp_price(@order.total)]

      t = Prawn::Table.new(cells, pdf)
      t.draw
    end
  end

  def filename
    "#{dir}/Invoice-#{@order.order_number}.pdf"
  end

  def dir
    "#{Rails.root.to_s}/public#{url_dir}"
  end

  def url_dir
    "/invoices/#{@order.hash.to_s}"
  end
end
