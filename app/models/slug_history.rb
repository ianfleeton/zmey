# Represents a past value of a slug for a page.
class SlugHistory < ApplicationRecord
  include TidySlug

  # Validations
  validate :page_with_slug_does_not_exist

  # Associations
  belongs_to :page

  # Callbacks
  before_save :delete_others_with_slug

  def self.add(page)
    SlugHistory.where(slug: page.slug).delete_all
    SlugHistory.create(page_id: page.id, slug: page.slug_was)
  end

  def delete_others_with_slug
    SlugHistory.where(slug: slug).delete_all
  end

  def page_with_slug_does_not_exist
    errors.add(:slug, "is already in use by a page") if Page.exists?(slug: slug)
  end
end
