class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.integer :topic_id, :default => 0, :null => false
      t.text :content
      t.string :author, :default => '', :null => false
      t.string :email, :default => '', :null => false

      t.timestamps
    end
    add_index :posts, :topic_id
  end

  def self.down
    drop_table :posts
  end
end
