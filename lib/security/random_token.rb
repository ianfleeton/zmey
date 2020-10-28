module Security
  # Generates a secure random token string safe for use in URLs.
  class RandomToken
    def initialize
      @token = SecureRandom.urlsafe_base64
    end

    def to_str
      @token
    end
    alias_method :to_s, :to_str
  end
end
