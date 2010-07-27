class Page < ActiveRecord::Base
  acts_as_tree :order => :position
  acts_as_list :scope => :parent_id

  has_many :product_placements, :order => :position, :include => :product, :dependent => :delete_all
  has_many :products, :through => :product_placement
  belongs_to :image

  attr_protected :website_id
  validates_presence_of :title, :name, :keywords, :description, :website_id
  validates_format_of :slug, :with => /\A[-a-z0-9]+\Z/, :message => 'can only contain letters, numbers and hyphens', :allow_blank => true
  validates_uniqueness_of :slug, :scope => :website_id, :case_sensitive => false
  validates_uniqueness_of :title, :scope => :website_id, :case_sensitive => false
  validates_uniqueness_of :name, :scope => :website_id, :case_sensitive => false

  def self.bootstrap website
    primary_nav_page = create_navigation website, 'primary'
    create_home_page website, primary_nav_page
  end

  def self.create_home_page website, nav_page
    create(
      :title => website.name,
      :name => 'Home',
      :keywords => 'change me',
      :description => 'change me',
      :content => 'Welcome to ' + website.name,
      :parent_id => nav_page.id
    ) {|hp| hp.website_id = website.id}
  end
  
  def self.create_navigation website, slug
    create(
      :title => slug.titleize + ' Navigation',
      :name => slug.titleize + ' Navigation',
      :slug => slug,
      :keywords => slug,
      :description => slug
    ) {|hp| hp.website_id = website.id}
  end

  def self.navs website_id
    navs = Array.new
    nav_roots = Page.all(:conditions => ['website_id = ? AND parent_id IS NULL', website_id], :order => :position)
    nav_roots.each do |nr|
      nav = Navigation.new
      nav.id_attribute = nr.slug.gsub('-', '_') + '_nav'
      nav.pages = Page.all(:conditions => ['parent_id = ?', nr.id], :order => :position)
      navs << nav 
    end
    navs
  end

  def to_param
    slug
  end

  # http://blog.airbladesoftware.com/2008/3/19/moving-between-lists-with-acts_as_list
  def parent_id=(parent_id)
    p = position
    remove_from_list if (p && valid?)
    super
    insert_at position_in_bounds(p) if (p && valid?)
  end

  # http://blog.airbladesoftware.com/2008/3/19/moving-between-lists-with-acts_as_list
  def move_to_position(position)
    insert_at position_in_bounds(position)
  end
  
  private
  
  # http://blog.airbladesoftware.com/2008/3/19/moving-between-lists-with-acts_as_list
  def position_in_bounds(pos)
    return 1 if parent.nil?
    length = parent.children.length
    length += 1 unless parent.children.include? self
    if pos < 1
      1
    elsif pos > length
      length
    else
      pos
    end
  end
end