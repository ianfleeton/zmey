class Page < ActiveRecord::Base
  attr_protected :website_id
  validates_presence_of :title, :name, :slug, :keywords, :description

  def to_param
    slug
  end
end