class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.integer :user_id
      t.string :order_number, :default => '', :null => false
      t.string :email_address, :default => '', :null => false
      t.string :full_name, :default => '', :null => false
      t.string :address_line_1, :default => '', :null => false
      t.string :address_line_2, :default => '', :null => false
      t.string :town_city, :default => '', :null => false
      t.string :county, :default => '', :null => false
      t.string :postcode, :default => '', :null => false
      t.integer :country_id, :default => 0, :null => false
      t.string :phone_number, :default => '', :null => false
      t.decimal :shipping_amount, :precision => 10, :scale => 3, :default => 0, :null => false
      t.string :shipping_method, :default => '', :null => false
      t.integer :status, :default => 0, :null => false
      t.decimal :total, :precision => 10, :scale => 3, :default => 0, :null => false

      t.timestamps
    end
    add_index :orders, :user_id
    add_index :orders, :created_at
    add_index :orders, :email_address
  end

  def self.down
    drop_table :orders
  end
end
