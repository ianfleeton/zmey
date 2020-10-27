class AddLoggedInToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :logged_in, :boolean, null: false, default: false
  end
end
