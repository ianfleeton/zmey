class Page < ActiveRecord::Base
  include ExtraAttributes

  acts_as_tree order: :position, dependent: :nullify
  validate :parent_cannot_be_self
  validate :parent_cannot_be_a_child
  acts_as_list scope: :parent_id

  has_many :product_placements, -> { order("position") }, dependent: :delete_all
  has_many :products, through: :product_placements
  has_many(
    :shortcuts,
    class_name: "Page", foreign_key: "canonical_page_id", dependent: :destroy
  )
  has_many :slug_histories, dependent: :delete_all
  belongs_to :canonical_page, class_name: "Page", optional: true
  belongs_to :image, optional: true
  belongs_to :thumbnail_image, class_name: "Image", optional: true

  validates_presence_of :title, :name
  validates :description, presence: true, length: {maximum: 200}
  validates_format_of :slug, with: /\A[-a-z0-9_\/\.]+\Z/,
                             message: "can only contain lowercase letters, numbers, hyphens, dots, underscores and forward slashes",
                             allow_blank: true
  validates_uniqueness_of :slug, case_sensitive: false
  validates_uniqueness_of :title, case_sensitive: false
  validates_uniqueness_of :name, scope: :parent_id, case_sensitive: false, unless: proc { |page| page.parent_id.nil? }

  # Active Record callbacks
  before_save :cache_name_with_ancestors
  before_update :record_slug_history

  scope :visible, -> { where(visible: true) }

  liquid_methods :image, :name, :path, :url

  nilify_blanks only: [:extra]

  def active_product_placements
    product_placements.joins(:product).where(products: {active: true}).includes(:product)
  end

  # Caches the results of name_with_ancestors into cached_name_with_ancestors,
  # only if this page's name or parent_id has been changed.
  def cache_name_with_ancestors
    if attribute_changed?(:name) || attribute_changed?(:parent_id)
      cache_name_with_ancestors!
    end
  end

  # Caches the results of name_with_ancestors into cached_name_with_ancestors.
  def cache_name_with_ancestors!
    self.cached_name_with_ancestors = name_with_ancestors
    children.reload.each do |c|
      c.cache_name_with_ancestors!
      c.save
    end
  end

  def name_with_ancestors
    parent ? parent.name_with_ancestors + " > " + name : name
  end

  # Returns pages matched by search +query+.
  def self.admin_search(query)
    words = query.split(" ")
    q = Page
    words.each do |word|
      fuzzy = "%#{word}%"
      q = q.where(
        ["name LIKE ? OR slug LIKE ? OR title LIKE ?", fuzzy, fuzzy, fuzzy]
      )
    end
    q.limit(100)
  end

  def self.bootstrap website
    primary_nav_page = create_navigation website, "primary"
    create_home_page website, primary_nav_page
  end

  def self.create_home_page website, nav_page
    create(
      title: website.name,
      name: "Home",
      description: "change me",
      content: "Welcome to " + website.name,
      parent_id: nav_page.id
    )
  end

  def self.create_navigation website, slug
    create(
      title: slug.titleize + " Navigation",
      name: slug.titleize + " Navigation",
      slug: slug,
      description: slug
    )
  end

  def self.navs website_id
    navs = []
    nav_roots = Page.where(parent_id: nil).order("position")
    nav_roots.each do |nr|
      nav = Navigation.new
      nav.id_attribute = nr.slug.tr("-", "_") + "_nav"
      nav.pages = Page.where(parent_id: nr.id).order("position")
      navs << nav
    end
    navs
  end

  def url
    Website.first.url + "/" + slug
  end

  def to_s
    "/" + slug + " (" + title + ")"
  end

  def path
    "/" + slug
  end

  # Returns an array of ancestors with closest ancestor first.
  def ancestors
    p, a = self, []
    while (p = p.parent)
      a << p
    end
    a
  end

  def self.exportable_attributes
    importable_attributes
  end

  def self.importable_attributes
    attribute_names + extra_attribute_names
  end

  # Custom validations.

  def parent_cannot_be_self
    if parent == self
      errors.add(:parent_id, "cannot be self")
    end
  end

  def parent_cannot_be_a_child
    if descendants.include?(parent)
      errors.add(:parent_id, "cannot be a child")
    end
  end

  private

  def record_slug_history
    SlugHistory.add(self) if slug_changed?
  end
end
