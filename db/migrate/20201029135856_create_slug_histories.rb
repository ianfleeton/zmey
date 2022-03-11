class CreateSlugHistories < ActiveRecord::Migration[6.1]
  def change
    create_table :slug_histories do |t|
      t.references :page, null: false, foreign_key: true
      t.string :slug

      t.timestamps
    end
    add_index :slug_histories, :slug
  end
end
