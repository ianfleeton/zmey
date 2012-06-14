class AddGoogleTitleToProducts < ActiveRecord::Migration
  def change
    add_column :products, :google_title, :string, default: '', null: false
    add_column :products, :condition, :string, default: 'new', null: false
    add_column :products, :google_product_category, :string, default: '', null: false
    add_column :products, :product_type, :string, default: '', null: false
    add_column :products, :brand, :string, default: '', null: false
    add_column :products, :availability, :string, default: 'in stock', null: false
    add_column :products, :gtin, :string, default: '', null: false
    add_column :products, :mpn, :string, default: '', null: false
  end
end
