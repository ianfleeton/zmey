class CreateCarouselSlides < ActiveRecord::Migration
  def change
    create_table :carousel_slides do |t|
      t.integer :website_id, null: false
      t.integer :position, null: false
      t.integer :image_id, null: false
      t.string :caption, null: false
      t.string :link, null: false

      t.timestamps
    end
  end
end
