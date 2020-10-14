class AddDeliveryCutoffHourToWebsites < ActiveRecord::Migration[6.0]
  def change
    add_column :websites, :delivery_cutoff_hour, :integer, default: 10, null: false
  end
end
