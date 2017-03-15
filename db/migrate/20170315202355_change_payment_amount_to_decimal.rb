class ChangePaymentAmountToDecimal < ActiveRecord::Migration[5.1]
  def up
    remove_column :payments, :amount
    add_column :payments, :amount, :decimal, precision: 10, scale: 2, null: false
  end

  def down
    remove_column :payments, :amount
    add_column :payments, :amount, :string
  end
end
