class RenameRbswpToWorldpay < ActiveRecord::Migration
  def change
    rename_column :websites, :rbswp_test_mode, :worldpay_test_mode
    rename_column :websites, :rbswp_payment_response_password, :worldpay_payment_response_password
    rename_column :websites, :rbswp_installation_id, :worldpay_installation_id
    rename_column :websites, :rbswp_active, :worldpay_active
  end
end
