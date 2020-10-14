class AddCreditAccountToOrder < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :credit_account, :boolean, default: false, null: false
  end
end
