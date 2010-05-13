class AddImageToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :image_id, :integer, :default => nil, :null => true
  end

  def self.down
    remove_column :pages, :image_id
  end
end
