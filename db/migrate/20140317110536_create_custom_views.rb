class CreateCustomViews < ActiveRecord::Migration
  def change
    create_table :custom_views do |t|
      t.integer :website_id, null: false
      t.string :path
      t.string :locale
      t.string :format
      t.string :handler
      t.boolean :partial
      t.text :template

      t.timestamps
    end

    add_index :custom_views, [:website_id, :path]
  end
end
