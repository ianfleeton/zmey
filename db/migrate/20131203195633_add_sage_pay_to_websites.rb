class AddSagePayToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :sage_pay_active, :boolean, default: false, null: false
    add_column :websites, :sage_pay_vendor, :string, default: '', null: false
    add_column :websites, :sage_pay_pre_shared_key, :string, default: '', null: false
    add_column :websites, :sage_pay_test_mode, :boolean, default: false, null: false
  end
end
