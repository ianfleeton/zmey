class CarouselSlide < ActiveRecord::Base
  validates_presence_of :caption, :image_id, :link

  acts_as_list

  belongs_to :image

  before_validation :ensure_active_range

  def to_s
    caption
  end

  def ensure_active_range
    self.active_from  = Date.today - 1.day if active_from.nil?
    self.active_until = Date.today + 10.years if active_until.nil?
  end

  # Returns slides that, based on current time, are currently active.
  def self.active
    where('active_from <= ? AND active_until >= ?', DateTime.now, DateTime.now).order(:position)
  end
end
