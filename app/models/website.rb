class Website < ActiveRecord::Base
  validates_uniqueness_of :google_analytics_code
  validates_format_of :google_analytics_code, :with => /\AUA-\d\d\d\d\d\d\d-\d\Z/
  
  def self.for(domain, subdomains)
    website = find_by_domain(domain)
    unless subdomains.blank?
      website ||= find_by_subdomain(subdomains.first)
    end
    website
  end
end