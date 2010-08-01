class CreateDiscounts < ActiveRecord::Migration
  def self.up
    create_table :discounts do |t|
      t.integer :website_id, :default => 0, :null => false
      t.string :name, :default => '', :null => false
      t.string :coupon, :default => '', :null => false
      t.string :reward_type, :default => '', :null => false
      t.integer :free_products_group_id

      t.timestamps
    end
  end

  def self.down
    drop_table :discounts
  end
end
