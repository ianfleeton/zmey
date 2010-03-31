class Website < ActiveRecord::Base
  validates_uniqueness_of :google_analytics_code, :allow_blank => true
  validates_format_of :google_analytics_code, :with => /\AUA-\d\d\d\d\d\d(\d)?(\d)?-\d\Z/, :allow_blank => true
  validates_presence_of :name
  validates_inclusion_of :private, :in => [true, false]
  
  # RBS WorldPay validations
  validates_inclusion_of :rbswp_active, :in => [true, false]
  validates_inclusion_of :rbswp_test_mode, :in => [true, false]
  # these details are required only if RBS WorldPay is active
  validates_presence_of :rbswp_installation_id, :if => Proc.new { |website| website.rbswp_active? }
  validates_presence_of :rbswp_payment_response_password, :if => Proc.new { |website| website.rbswp_active? }

  has_one :preferred_delivery_date_settings, :dependent => :delete
  has_many :products, :order => :name, :dependent => :destroy
  has_many :orders, :order => 'created_at DESC', :dependent => :destroy
  has_many :pages, :order => 'name', :dependent => :destroy
  has_many :images, :dependent => :destroy
  has_many :forums, :dependent => :destroy
  has_many :enquiries, :dependent => :destroy
  has_many :users, :order => 'name', :dependent => :destroy
  belongs_to :blog, :class_name => 'Forum'
  
  def self.for(domain, subdomains)
    website = find_by_domain(domain)
    unless subdomains.blank?
      website ||= find_by_subdomain(subdomains.first)
    end
    website
  end
  
  def only_accept_payment_on_account?
    accept_payment_on_account and !(rbswp_active)
  end
end