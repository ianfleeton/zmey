class AddUpgAtlasFilenameToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :upg_atlas_filename, :string, default: '', null: false
  end
end
