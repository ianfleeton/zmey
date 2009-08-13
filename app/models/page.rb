class Page < ActiveRecord::Base
  attr_protected :website_id
  validates_presence_of :title, :name, :keywords, :description
  validates_format_of :slug, :with => /\A[-a-z0-9]+\Z/, :message => 'can only contain letters, numbers and hyphens', :allow_blank => true
  validates_uniqueness_of :slug, :scope => :website_id, :case_sensitive => false
  validates_uniqueness_of :title, :scope => :website_id, :case_sensitive => false
  validates_uniqueness_of :name, :scope => :website_id, :case_sensitive => false

  def self.create_home_page website
    Page.create(
      :title => website.name,
      :name => 'Home',
      :keywords => 'change me',
      :description => 'change me',
      :content => 'Welcome to ' + website.name
    ) {|hp| hp.website_id = website.id}
  end

  def to_param
    slug
  end
end