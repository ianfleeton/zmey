class AddShopperDetailsToBasket < ActiveRecord::Migration[6.0]
  def change
    add_column :baskets, :email, :string, limit: 191
    add_column :baskets, :mobile, :string
    add_column :baskets, :name, :string
    add_column :baskets, :phone, :string
    add_index :baskets, :email
    add_reference :baskets, :shipping_class, null: true
  end
end
