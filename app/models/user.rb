class User < ActiveRecord::Base
  belongs_to :website
  
  # unencrypted password
  attr_accessor :password
  
  attr_protected :admin, :manages_website_id, :website_id

  # associations
  belongs_to :managed_website, :foreign_key => :manages_website_id, :class_name => 'Website'

  # validation
  validates_length_of     :email, :within => 3..100
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :email, :case_sensitive => false, :message => 'has already been taken. If you have forgotten your password you can request a new one.'
  
  validates_presence_of   :name
  validates_length_of     :password, :within => 4..40,
                                     :if => :password_required?
  validates_confirmation_of :password, :if => :password_required?
  
  # callbacks
  before_save :encrypt_password

  # encrypts given password using salt
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{pass}--")
  end
  
  # authenticate by email/password
  def self.authenticate(email, pass)
    user = find_by_email(email)
    user && user.authenticated?(pass) ? user : nil
  end
  
  # does the given password match the stored encrypted password
  def authenticated?(pass)
    encrypted_password == User.encrypt(pass, salt)
  end
  
  def self.generate_forgot_password_token
    charset = %w{ 2 3 4 6 7 9 A C D E F G H J K L M N P Q R T V W X Y Z}
    (0...8).map{ charset.to_a[rand(charset.size)] }.join
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
