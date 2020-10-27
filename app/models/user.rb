class User < ActiveRecord::Base
  UNSET = "unset"

  # Associations
  has_many :orders, -> { order "created_at DESC" }, dependent: :nullify
  has_many :addresses, dependent: :delete_all
  has_many :api_keys, -> { order :name }, dependent: :delete_all

  # unencrypted password
  attr_accessor :password

  validates_uniqueness_of :customer_reference, allow_blank: true

  validates_length_of :email, within: 3..100
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email, case_sensitive: false, message: "has already been taken. If you have forgotten your password you can request a new one."

  validates_presence_of :name
  validates_length_of :password, within: 4..40,
                                 if: :password_required?
  validates_confirmation_of :password, if: :password_required?

  # callbacks
  before_create :set_email_verification_token
  before_save :encrypt_password

  # encrypts given password using salt
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{pass}--")
  end

  # authenticate by email/password
  def self.authenticate(email, pass)
    user = find_by(email: email)
    user&.authenticated?(pass) ? user : nil
  end

  # does the given password match the stored encrypted password
  def authenticated?(pass)
    encrypted_password == User.encrypt(pass, salt)
  end

  def self.generate_token
    charset = %w[2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z]
    (0...8).map { charset.to_a[rand(charset.size)] }.join
  end

  # Returns an existing customer account with matching email address, or
  # creates and returns a new one if needed.
  def self.find_or_create_by_details(email:, name:)
    (email && User.find_by(email: email.downcase)) ||
      User.create(email: email&.downcase, name: name, encrypted_password: UNSET)
  end

  # Returns an existing unverified user account with matching email address, or
  # creates and returns a new one if needed. Returns nil if the email address
  # matches an existing verified account.
  def self.unverified_user(email:, name:)
    # Avoid unnecessary database query.
    return nil unless email

    user = find_or_create_by_details(email: email, name: name)
    user if user&.persisted? && !user.email_verified_at
  end

  def self.temporary
    # Opt in is false for temporary users but true for new real ones.
    User.new(opt_in: false)
  end

  def to_s
    "#{name} <#{email}>"
  end

  def set_email_verification_token
    self.email_verification_token = self.class.generate_token
  end

  # Recording of explicit opt in for GDPR compliance.
  def update_explicit_opt_in(opting_in)
    if opting_in
      self.explicit_opt_in_at = Time.current
      self.opt_in = true
    else
      self.explicit_opt_in_at = nil
      self.opt_in = false
    end
  end

  # Opt in that uses PECR rules instead of GDPR. Opting in here
  # should not be considered an explicit opt in.
  def update_opt_in(opting_in)
    if opting_in
      self.opt_in = true
    else
      self.explicit_opt_in_at = nil
      self.opt_in = false
    end
  end

  def password_set?
    encrypted_password != UNSET
  end

  protected

  # before save - create salt, encrypt password
  def encrypt_password
    return if password.blank?
    if new_record?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now}--#{email}--")
    end
    self.encrypted_password = User.encrypt(password, salt)
  end

  # no encrypted password yet OR password attribute is set
  def password_required?
    encrypted_password.blank? || !password.blank?
  end
end
