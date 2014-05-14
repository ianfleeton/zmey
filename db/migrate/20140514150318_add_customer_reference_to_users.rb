class AddCustomerReferenceToUsers < ActiveRecord::Migration
  def change
    add_column :users, :customer_reference, :string, default: '', null: false
  end
end
