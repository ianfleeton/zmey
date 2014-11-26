class RemoveWebsiteIdFromProducts < ActiveRecord::Migration
  def up
    remove_column :products, :website_id
  end

  def down
    add_column :products, :website_id, :integer
    add_index :products, :website_id
  end
end
