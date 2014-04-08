class ApiKey < ActiveRecord::Base
  belongs_to :user

  validates :name, format: /\A[-a-zA-Z0-9]+\Z/, uniqueness: { scope: :user_id }
  validates :user_id, presence: true

  before_create :generate_key

  private

    def generate_key
      loop do
        self.key = SecureRandom.hex
        break unless ApiKey.find_by(key: key)
      end
    end
end
