class AddImageSizesToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :page_image_size, :integer, :default => 400, :nil => false
    add_column :websites, :page_thumbnail_size, :integer, :default => 200, :nil => false
    add_column :websites, :product_image_size, :integer, :default => 400, :nil => false
    add_column :websites, :product_thumbnail_size, :integer, :default => 200, :nil => false
  end

  def self.down
    remove_column :websites, :page_image_size
    remove_column :websites, :page_thumbnail_size
    remove_column :websites, :product_image_size
    remove_column :websites, :product_thumbnail_size
  end
end
