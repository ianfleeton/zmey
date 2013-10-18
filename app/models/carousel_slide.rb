class CarouselSlide < ActiveRecord::Base
  validates_presence_of :caption, :image_id, :link

  acts_as_list scope: :website_id

  belongs_to :image
  belongs_to :website

  def to_s
    caption
  end
end
