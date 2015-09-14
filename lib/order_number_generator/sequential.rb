module OrderNumberGenerator
  # Generates sequential order numbers.
  class Sequential < Base
    def generate
      (Order.maximum(:order_number).to_i + 1).to_s
    end
  end
end
