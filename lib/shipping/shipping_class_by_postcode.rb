# frozen_string_literal: true

module Shipping
  # Finds a matching shipping class by matching the postcode against the list
  # of postcode regexes in each shipping class's postcode_districts attribute.
  # It defaults to Mainland UK if no other shipping class matches the given
  # postcode.
  class ShippingClassByPostcode
    attr_reader :postcode

    def initialize(postcode:)
      @postcode = Formatters::Postcode.new(postcode.to_s).format
    end

    def find
      all_classes.find do |sc|
        matches?(sc)
      end || ShippingClass.mainland
    end

    def find_all
      filtered = all_classes.select { |sc| matches?(sc) }
      filtered.any? ? filtered : [ShippingClass.mainland].compact
    end

    def matches?(sc)
      sc.postcode_districts.to_s.split.each do |regex|
        # Assume short regexes are postcode districts and tweak the regex
        # accordingly.
        regex = postcode_district_regex(regex) if regex.length < 5
        return true if /#{regex}/.match?(postcode)
      end
      false
    end

    def all_classes
      ShippingClass.all.to_a
    end

    private

    def postcode_district_regex(regex)
      # Assume a space is required after.
      # This prevents IV3 regex from matching an IV32 postcode.
      # Assume the string must start with the district.
      # This prevents DE45 matching E45.
      '\A' + regex + '\s'
    end
  end
end
