class AddOrderNotifierEmailToWebsites < ActiveRecord::Migration[6.0]
  def change
    add_column :websites, :order_notifier_email, :string
  end
end
