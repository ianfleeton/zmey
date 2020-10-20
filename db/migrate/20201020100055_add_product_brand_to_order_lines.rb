class AddProductBrandToOrderLines < ActiveRecord::Migration[6.0]
  def change
    add_column :order_lines, :product_brand, :string, default: "", null: false
  end
end
