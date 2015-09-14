module OrderNumberGenerator
  # Order numbers include date but are not sequential so as to prevent
  # competitor analysis of sales volume.
  class DatedRandom < Base
    def generate
      alpha = %w(0 1 2 3 4 5 6 7 8 9 A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
      # try a short order number first
      # in case of collision, increase length of order number
      order_number = ''
      (4..10).each do |length|
        order_number = Time.now.strftime("%Y%m%d-")
        length.times {order_number += alpha[rand 36]}
        existing_order = Order.find_by(order_number: order_number)
        break if existing_order.nil?
      end
      order_number
    end
  end
end
