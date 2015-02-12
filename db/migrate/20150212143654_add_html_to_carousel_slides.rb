class AddHtmlToCarouselSlides < ActiveRecord::Migration
  def change
    add_column :carousel_slides, :html, :text
  end
end
