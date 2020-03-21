module QuantityPricesHelper
  def quantity_prices_table(product)
    rules = product.quantity_prices.to_ary
    return if rules.empty?
    first = "1"
    first += "&#8211;#{rules.first.quantity - 1}" unless rules.first.quantity == 2
    html = <<HTML
      <table class="table table-striped">
        <tr>
          <th>Quantity</th>
          <th>Price</th>
          <th>Actions</th>
        </tr>
        <tr>
          <td>#{first}</td>
          <td>#{formatted_price(product.price_with_tax(1, @inc_tax))}</td>
          <td>&nbsp;</td>
        </tr>
HTML
    rules.each_index do |i|
      qp = rules[i]
      qp_next = rules.last == qp ? nil : rules[i + 1]
      html << "<tr>"
      html << "<td>#{qp.quantity}#{qp_next ? "&#8211;" + (qp_next.quantity - 1).to_s : "+"}</td>"
      html << "<td>#{formatted_price(product.price_with_tax(qp.quantity, @inc_tax))}</td>"
      if block_given?
        end_of_row = capture { yield qp }
        html << end_of_row
      end
    end
    html << "</table>"
    concat(html.html_safe)
  end
end
