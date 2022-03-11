class CreateCollectionReadyEmails < ActiveRecord::Migration[6.1]
  def change
    create_table :collection_ready_emails do |t|
      t.references :order, null: false, foreign_key: true
      t.datetime :sent_at

      t.timestamps
    end
  end
end
