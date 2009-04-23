class Website < ActiveRecord::Base
  def self.for(domain, subdomains)
    website = find_by_domain(domain)
    unless subdomains.blank?
      website ||= find_by_subdomain(subdomains.first)
    end
    website
  end
end