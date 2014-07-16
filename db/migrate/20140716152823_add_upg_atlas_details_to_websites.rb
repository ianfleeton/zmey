class AddUpgAtlasDetailsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :upg_atlas_active, :boolean, default: false, null: false
    add_column :websites, :upg_atlas_sh_reference, :string, default: '', null: false
    add_column :websites, :upg_atlas_check_code, :string, default: '', null: false
  end
end
