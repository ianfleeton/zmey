module TidySlug
  extend ActiveSupport::Concern

  included do
    validates_format_of :slug, with: /\A[-a-z0-9_\/.]+\Z/,
      message: "can only contain lowercase letters, numbers, hyphens, dots, underscores and forward slashes",
      allow_blank: true
    validates_length_of :slug, maximum: 191
    before_validation :tidy_slug
  end

  def tidy_slug
    self.slug = slug.gsub(/^\/+/, "") if slug
  end
end
