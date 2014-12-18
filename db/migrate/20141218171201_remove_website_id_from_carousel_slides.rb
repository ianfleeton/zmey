class RemoveWebsiteIdFromCarouselSlides < ActiveRecord::Migration
  def up
    remove_column :carousel_slides, :website_id
  end

  def down
    add_column :carousel_slides, :website_id, null: false
  end
end
