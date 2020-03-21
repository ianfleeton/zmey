module Enums
  module Conversions
    module_function

    def PaymentStatus(status)
      case status
      when PaymentStatus then status
      when Integer then PaymentStatus.new(status)
      when String then PaymentStatus.from_api(status)
      else
        raise TypeError, "Cannot convert #{status.inspect} to PaymentStatus"
      end
    end
  end
end
