class AddVatNumberToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :vat_number, :string
  end
end
