# frozen_string_literal: true

require "digest"

module Security
  # Generates a fingerprint for an object by hashing the provided attributes.
  class Fingerprint
    attr_reader :object, :attributes

    def initialize(object, attributes)
      @object = object
      @attributes = attributes
    end

    def to_s
      md5(attribute_string)
    end
    alias_method :hash, :to_s

    def ==(other)
      to_s == other.to_s
    end

    private

    def attribute_string
      attributes.map { |a|
        val = object.send(a)
        if val.is_a?(ActiveSupport::TimeWithZone)
          val.to_i
        else
          val
        end
      }.join("--")
    end

    def md5(str)
      Digest::MD5.hexdigest(str)
    end
  end
end
