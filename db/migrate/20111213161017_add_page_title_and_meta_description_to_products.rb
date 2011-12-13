class AddPageTitleAndMetaDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :page_title, :string, :default => '', :null => false
    add_column :products, :meta_description, :string, :default => '', :null => false
  end
end
