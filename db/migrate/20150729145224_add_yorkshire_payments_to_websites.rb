class AddYorkshirePaymentsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :yorkshire_payments_active, :boolean, default: false, null: false
    add_column :websites, :yorkshire_payments_merchant_id, :string, default: '', null: false
    add_column :websites, :yorkshire_payments_pre_shared_key, :string, default: '', null: false
  end
end
