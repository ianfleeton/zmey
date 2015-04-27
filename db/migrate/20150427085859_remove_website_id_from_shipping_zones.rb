class RemoveWebsiteIdFromShippingZones < ActiveRecord::Migration
  def up
    remove_column :shipping_zones, :website_id
  end

  def down
    add_column :shipping_zones, :website_id, :integer, default: 0,  null: false
  end
end
