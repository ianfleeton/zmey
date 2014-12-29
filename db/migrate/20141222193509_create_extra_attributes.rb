class CreateExtraAttributes < ActiveRecord::Migration
  def change
    create_table :extra_attributes do |t|
      t.string :class_name
      t.string :attribute

      t.timestamps null: false
    end
  end
end
