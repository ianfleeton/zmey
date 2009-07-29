class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :email, :default => '', :null => false
      t.string  :name, :default => '', :null => false
      t.string  :encrypted_password
      t.string  :salt
      t.string  :forgot_password_token, :default => '', :null => false
      t.boolean :admin, :default => 0, :null => false
      t.integer :manages_website_id, :default => 0, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
