class AddThumbnailImageIdToPages < ActiveRecord::Migration
  def change
    add_column :pages, :thumbnail_image_id, :integer
    add_index :pages, :thumbnail_image_id
  end
end
