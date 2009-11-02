class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :topic, :default => '', :null => false
      t.integer :forum_id, :default => 0, :null => false
      t.integer :posts_count, :default => 0, :null => false
      t.integer :views, :default => 0, :null => false
      t.integer :last_post_id, :default => 0, :null => false
      t.string :last_post_author, :default => '', :null => false
      t.datetime :last_post_at, :default => '0000-00-00 00:00:00', :null => false

      t.timestamps
    end
    add_index :topics, :last_post_at
    add_index :topics, :forum_id
  end

  def self.down
    drop_table :topics
  end
end
