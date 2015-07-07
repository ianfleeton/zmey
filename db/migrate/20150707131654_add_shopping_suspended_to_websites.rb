class AddShoppingSuspendedToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :shopping_suspended, :boolean, default: false, null: false
    add_column :websites, :shopping_suspended_message, :string
  end
end
