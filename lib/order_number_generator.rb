module OrderNumberGenerator
  module_function

  def get_generator(order)
    DatedRandom.new(order)
  end
end
