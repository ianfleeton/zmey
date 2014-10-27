class AddGoogleDescriptionToProducts < ActiveRecord::Migration
  def change
    add_column :products, :google_description, :text
  end
end
