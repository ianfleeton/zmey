class AddMobileNumbersToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :billing_mobile_number, :string
    add_column :orders, :delivery_mobile_number, :string
  end
end
