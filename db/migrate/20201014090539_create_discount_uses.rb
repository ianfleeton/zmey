class CreateDiscountUses < ActiveRecord::Migration[6.0]
  def change
    create_table :discount_uses do |t|
      t.references :order, null: false, foreign_key: true
      t.references :discount, null: false, foreign_key: true

      t.timestamps
    end
  end
end
