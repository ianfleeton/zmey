class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.column :title, :string, default: '', null: false
      t.column :slug,  :string, default: '', null: false
      t.column :website_id, :integer, null: false
      t.timestamps
    end
    add_index :pages, :website_id
    add_index :pages, :slug
  end

  def self.down
    drop_table :pages
  end
end
