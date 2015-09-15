class AddDefaultShippingClassIdToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :default_shipping_class_id, :integer
  end
end
