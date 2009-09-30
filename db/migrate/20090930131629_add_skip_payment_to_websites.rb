class AddSkipPaymentToWebsites < ActiveRecord::Migration
  def self.up
    add_column :websites, :skip_payment, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :websites, :skip_payment
  end
end
