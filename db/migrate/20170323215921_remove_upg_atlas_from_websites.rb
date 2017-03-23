class RemoveUpgAtlasFromWebsites < ActiveRecord::Migration[5.1]
  def change
    remove_column :websites, :upg_atlas_active
    remove_column :websites, :upg_atlas_sh_reference
    remove_column :websites, :upg_atlas_check_code
    remove_column :websites, :upg_atlas_filename
    remove_column :websites, :upg_atlas_secuphrase
  end
end
