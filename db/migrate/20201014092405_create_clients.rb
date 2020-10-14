class CreateClients < ActiveRecord::Migration[6.0]
  def change
    create_table :clients do |t|
      t.integer :clientable_id, null: false
      t.string :clientable_type, null: false
      t.string :ip_address, limit: 45
      t.string :platform, default: "web", null: false
      t.string :device
      t.text :user_agent
      t.string :operating_system
      t.string :browser
      t.string :browser_version
      t.timestamps
    end
    add_index :clients, [:clientable_type, :clientable_id]
    add_index :clients, :ip_address
  end
end
