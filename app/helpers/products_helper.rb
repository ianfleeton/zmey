module ProductsHelper
  def formatted_price price
    number_to_currency(price, :unit => '&pound;')
  end
  def formatted_gbp_price price
    number_to_currency(price, :unit => 'GBP', :format => '%n %u')
  end
end
