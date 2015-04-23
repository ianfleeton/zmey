class AddInvalidOverHighestTriggerToShippingClasses < ActiveRecord::Migration
  def change
    add_column :shipping_classes, :invalid_over_highest_trigger, :boolean, default: false, null: false
  end
end
