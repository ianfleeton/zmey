class AddAllowOversizeToShippingClasses < ActiveRecord::Migration
  def change
    add_column :shipping_classes, :allow_oversize, :boolean, default: true, null: false
  end
end
