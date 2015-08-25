module YorkshirePayments
  class Signature
    def initialize(fields, pre_shared_key)
      @fields = fields
      @pre_shared_key = pre_shared_key
    end

    def sign
      hash(to_hash(@fields))
    end

    def verify
      # Remove and store signature from field list
      fields = @fields.clone
      signature = ''
      fields.delete_if {|f| (f[0] == 'signature') && signature = f[1]}

      if signature.present?
        hash(to_hash(fields)) == signature
      end
    end

    private

      def hash(string)
        Digest::SHA512.hexdigest(string)
      end

      def to_hash(fields)
        # Fields must be sorted first, then URL-encoded and line endings
        # normalised.
        fields
          .sort {|a,b| a[0] <=> b[0]}
          .map  {|a| "#{a[0]}=#{CGI.escape(a[1])}"}
          .join('&')
          .gsub(/%0D%0A|%0A%0D|%0A|%0D/, '%0A') + @pre_shared_key
      end
  end
end
