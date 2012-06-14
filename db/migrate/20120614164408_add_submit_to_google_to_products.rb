class AddSubmitToGoogleToProducts < ActiveRecord::Migration
  def change
    add_column :products, :submit_to_google, :boolean, default: true, null: false
  end
end
