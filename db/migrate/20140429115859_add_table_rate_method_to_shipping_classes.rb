class AddTableRateMethodToShippingClasses < ActiveRecord::Migration
  def change
    add_column :shipping_classes, :table_rate_method, :string, default: 'basket_total', null: false
  end
end
