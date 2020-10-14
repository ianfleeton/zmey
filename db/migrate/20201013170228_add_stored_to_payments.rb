class AddStoredToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :stored, :boolean, null: false, default: false
  end
end
