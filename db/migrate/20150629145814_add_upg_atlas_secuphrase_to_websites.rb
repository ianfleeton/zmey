class AddUpgAtlasSecuphraseToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :upg_atlas_secuphrase, :string
  end
end
