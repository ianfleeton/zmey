# frozen_string_literal: true

module Formatters
  # Formats UK postcodes.
  class Postcode
    attr_reader :postcode

    def initialize(postcode)
      @postcode = postcode
    end

    # Returns a trimmed and uppercased UK postcode with a space in the
    # correct place.
    #
    #   Postcode.new('  dn12 Qp ').format
    #   # => 'DN1 2QP'
    def format
      spacify(postcode.upcase)
    end

    # Returns the left-hand portion of a formatted UK postcode.
    #
    #   Postcode.new(" yo18 1ab ").district
    #   # => "YO18"
    def district
      format.split(" ")[0]
    end

    private

    def spacify(str)
      str = str.gsub(/\s+/, "")
      formats.each do |fmt|
        str = str.insert(fmt[1], " ") if fmt[0].match(str)
      end
      str
    end

    def formats
      [
        # [Matching regex, index to insert space]
        [/\A[A-Z][A-Z]\d[A-Z]\d[A-Z][A-Z]\Z/, 4],
        [/\A[A-Z]\d[A-Z]\d[A-Z][A-Z]\Z/, 3],
        [/\A[A-Z]\d\d[A-Z][A-Z]\Z/, 2],
        [/\A[A-Z]\d\d\d[A-Z][A-Z]\Z/, 3],
        [/\A[A-Z][A-Z]\d\d[A-Z][A-Z]\Z/, 3],
        [/\A[A-Z][A-Z]\d\d\d[A-Z][A-Z]\Z/, 4],
        eircode
      ]
    end

    def eircode
      [
        /
          \A(A|C|D|E|F|H|K|N|P|R|T|V|W|X|Y)([0-9])
          ([0-9]|W)([0-9]|A|C|D|E|F|H|K|N|P|R|T|V|W|X){4}\Z
        /x,
        3
      ]
    end
  end
end
