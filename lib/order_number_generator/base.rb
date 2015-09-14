module OrderNumberGenerator
  # Base class for order number generators.
  class Base
    def initialize(order)
      @order = order
    end
  end
end
