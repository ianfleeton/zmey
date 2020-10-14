# frozen_string_literal: true

module OrderNumberGenerator
  module_function

  def get_generator(order)
    Sequential.new(order)
  end
end
