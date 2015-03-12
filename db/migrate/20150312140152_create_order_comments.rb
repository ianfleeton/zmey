class CreateOrderComments < ActiveRecord::Migration
  def change
    create_table :order_comments do |t|
      t.integer :order_id, null: false
      t.text :comment

      t.timestamps null: false
    end

    add_index :order_comments, :order_id
  end
end
