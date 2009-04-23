class CreateWebsites < ActiveRecord::Migration
  def self.up
    create_table :websites do |t|
      t.column  :subdomain, :string, :default => '', :null => false
      t.column  :domain, :string, :default => '', :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :websites
  end
end
