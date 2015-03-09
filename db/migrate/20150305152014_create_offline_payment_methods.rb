class CreateOfflinePaymentMethods < ActiveRecord::Migration
  def change
    create_table :offline_payment_methods do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end
