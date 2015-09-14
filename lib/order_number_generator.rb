module OrderNumberGenerator
  def self.get_generator(order)
    DatedRandom.new(order)
  end
end
