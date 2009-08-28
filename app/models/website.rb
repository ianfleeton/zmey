class Website < ActiveRecord::Base
  validates_uniqueness_of :google_analytics_code, :allow_blank => true
  validates_format_of :google_analytics_code, :with => /\AUA-\d\d\d\d\d\d(\d)?-\d\Z/, :allow_blank => true
  validates_presence_of :name
  
  # RBS WorldPay validations
  validates_inclusion_of :rbswp_active, :in => [true, false]
  validates_inclusion_of :rbswp_test_mode, :in => [true, false]
  # these details are required only if RBS WorldPay is active
  validates_presence_of :rbswp_installation_id, :if => Proc.new { |website| website.rbswp_active? }
  validates_presence_of :rbswp_payment_response_password, :if => Proc.new { |website| website.rbswp_active? }
  
  has_many :products, :order => :name
  has_many :orders, :order => 'created_at DESC'
  
  def self.for(domain, subdomains)
    website = find_by_domain(domain)
    unless subdomains.blank?
      website ||= find_by_subdomain(subdomains.first)
    end
    website
  end
end