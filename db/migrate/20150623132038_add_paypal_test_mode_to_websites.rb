class AddPaypalTestModeToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :paypal_test_mode, :boolean, default: false, null: false
  end
end
