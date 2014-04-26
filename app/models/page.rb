class Page < ActiveRecord::Base
  acts_as_tree order: :position
  acts_as_list scope: :parent_id

  has_many :product_placements, -> { order('position') }, dependent: :delete_all
  has_many :products, through: :product_placements
  belongs_to :image
  belongs_to :website

  validates_presence_of :title, :name, :website_id
  validates :description, presence: true, length: { maximum: 200 }
  validates_format_of :slug, with: /\A[-a-z0-9_\/\.]+\Z/,
    message: 'can only contain lowercase letters, numbers, hyphens, dots, underscores and forward slashes',
    allow_blank: true
  validates_uniqueness_of :slug, scope: :website_id, case_sensitive: false
  validates_uniqueness_of :title, scope: :website_id, case_sensitive: false
  validates_uniqueness_of :name, scope: :parent_id, case_sensitive: false, unless: Proc.new { |page| page.parent_id.nil? }

  liquid_methods :image, :name, :path, :url

  def active_product_placements
    product_placements.joins(:product).where(products: { active: true }).includes(:product)
  end

  def name_with_ancestors
    parent ? parent.name_with_ancestors + ' > ' + name : name
  end

  def self.bootstrap website
    primary_nav_page = create_navigation website, 'primary'
    create_home_page website, primary_nav_page
  end

  def self.create_home_page website, nav_page
    create(
      title: website.name,
      name: 'Home',
      description: 'change me',
      content: 'Welcome to ' + website.name,
      parent_id: nav_page.id
    ) {|hp| hp.website_id = website.id}
  end

  def self.create_navigation website, slug
    create(
      title: slug.titleize + ' Navigation',
      name: slug.titleize + ' Navigation',
      slug: slug,
      description: slug
    ) {|hp| hp.website_id = website.id}
  end

  def self.navs website_id
    navs = Array.new
    nav_roots = Page.where(website_id: website_id, parent_id: nil).order('position')
    nav_roots.each do |nr|
      nav = Navigation.new
      nav.id_attribute = nr.slug.gsub('-', '_') + '_nav'
      nav.pages = Page.where(parent_id: nr.id).order('position')
      navs << nav
    end
    navs
  end

  def url
    'http://' + website.domain + '/' + slug
  end

  def to_s
    '/' + slug + ' (' + title + ')'
  end

  def path
    return '/' + slug
  end

  def parent_id=(parent_id)
    self.position = 1
    super
  end
end
