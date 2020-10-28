class AddEmailConfirmationTokenToOrders < ActiveRecord::Migration[6.0]
  def change
    add_column :orders, :email_confirmation_token, :string, default: "", null: false
  end
end
