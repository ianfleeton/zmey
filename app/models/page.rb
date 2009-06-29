class Page < ActiveRecord::Base
  attr_protected :website_id
  validates_presence_of :title, :name, :slug, :keywords, :description
  validates_format_of :slug, :with => /\A[-a-z0-9]+\Z/, :message => 'can only contain letters, numbers and hyphens'
  validates_uniqueness_of :slug, :scope => :website_id, :case_sensitive => false
  validates_uniqueness_of :title, :scope => :website_id, :case_sensitive => false
  validates_uniqueness_of :name, :scope => :website_id, :case_sensitive => false

  def to_param
    slug
  end
end