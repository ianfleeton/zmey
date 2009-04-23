class CreateWebsites < ActiveRecord::Migration
  def self.up
    create_table :websites do |t|
      t.string  :subdomain
      t.string  :domain
      t.timestamps
    end
  end

  def self.down
    drop_table :websites
  end
end
