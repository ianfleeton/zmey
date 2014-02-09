class AddActiveFromAndActiveUntilToCarouselSlides < ActiveRecord::Migration
  def change
    add_column :carousel_slides, :active_from, :datetime, null: false
    add_column :carousel_slides, :active_until, :datetime, null: false
  end
end
