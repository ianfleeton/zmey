class Page < ActiveRecord::Base
  include ExtraAttributes

  acts_as_tree order: :position, dependent: :nullify
  validate :parent_cannot_be_self
  validate :parent_cannot_be_a_child
  acts_as_list scope: :parent_id

  has_many :product_placements, -> { order("position") }, dependent: :delete_all
  has_many :products, through: :product_placements
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

  scope :visible, -> { where(visible: true) }

  liquid_methods :image, :name, :path, :url

  nilify_blanks only: [:extra]

  def active_product_placements
    product_placements.joins(:product).where(products: {active: true}).includes(:product)
  end

  def name_with_ancestors
    parent ? parent.name_with_ancestors + " > " + name : name
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
end
