class CreateWebhooks < ActiveRecord::Migration
  def change
    create_table :webhooks do |t|
      t.integer :website_id, null: false
      t.string :event, null: false
      t.string :url, null: false

      t.timestamps
    end

    add_index :webhooks, [:website_id, :event]
  end
end
