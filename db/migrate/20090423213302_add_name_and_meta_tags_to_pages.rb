class AddNameAndMetaTagsToPages < ActiveRecord::Migration
  def self.up
    add_column :pages, :name, :string, :default => "", :null => false
    add_column :pages, :keywords, :string, :default => "", :null => false
    add_column :pages, :description, :string, :default => "", :null => false
  end

  def self.down
    remove_column :pages, :name
    remove_column :pages, :keywords
    remove_column :pages, :description
  end
end
