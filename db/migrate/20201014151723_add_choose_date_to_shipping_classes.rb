class AddChooseDateToShippingClasses < ActiveRecord::Migration[6.0]
  def change
    add_column :shipping_classes, :choose_date, :boolean, null: false, default: false
  end
end
