class CarouselSlide < ActiveRecord::Base
  attr_accessible :caption, :image_id, :link, :position, :website_id

  validates_presence_of :caption, :image_id, :link

  acts_as_list scope: :website_id
end
