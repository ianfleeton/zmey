class RemoveWebsiteIdFromLiquidTemplates < ActiveRecord::Migration
  def up
    remove_column :liquid_templates, :website_id
  end

  def down
    add_column :liquid_templates, :website_id, :integer, null: false
    add_index :liquid_templates, :website_id
  end
end
