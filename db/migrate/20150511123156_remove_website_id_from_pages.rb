class RemoveWebsiteIdFromPages < ActiveRecord::Migration
  def up
    remove_column :pages, :website_id
  end

  def down
    add_column :pages, :website_id, :integer, null: false
    add_index :pages, :website_id
  end
end
