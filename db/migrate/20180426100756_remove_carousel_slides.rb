class RemoveCarouselSlides < ActiveRecord::Migration[5.1]
  def up
    drop_table :carousel_slides
  end

  def down
    create_table "carousel_slides", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci" do |t|
      t.integer "position", null: false
      t.integer "image_id", null: false
      t.string "caption", null: false
      t.string "link", null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.datetime "active_from", null: false
      t.datetime "active_until", null: false
      t.text "html"
    end
  end
end
