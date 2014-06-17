class AddIndexOnWebsiteIdToProducts < ActiveRecord::Migration
  def change
    add_index :products, :website_id
  end
end
