class RemoveWebsiteIdFromNominalCodes < ActiveRecord::Migration
  def up
    remove_column :nominal_codes, :website_id
  end

  def down
    add_column :nominal_codes, :website_id, :integer, null: false
    add_index :nominal_codes, :website_id
  end
end
