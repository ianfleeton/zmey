class CarouselSlide < ActiveRecord::Base
  validates_presence_of :caption, :image_id, :link

  acts_as_list scope: :website_id

  belongs_to :image
  belongs_to :website

  before_validation :ensure_active_range

  def to_s
    caption
  end

  def ensure_active_range
    self.active_from  = Date.today - 1.day if active_from.nil?
    self.active_until = Date.today + 10.years if active_until.nil?
  end
end
