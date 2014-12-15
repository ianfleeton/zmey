class RemoveWebsiteIdFromCountries < ActiveRecord::Migration
  def up
    remove_column :countries, :website_id
  end

  def down
    add_column :countries, :website_id, :integer, default: 0,  null: false
    add_index :countries, :website_id
  end
end
