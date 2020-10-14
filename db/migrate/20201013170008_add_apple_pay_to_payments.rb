class AddApplePayToPayments < ActiveRecord::Migration[6.0]
  def change
    add_column :payments, :apple_pay, :boolean, default: false, null: false
  end
end
