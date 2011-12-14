class AddCardsaveToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :cardsave_active, :boolean, :default => false, :null => false
    add_column :websites, :cardsave_merchant_id, :string, :default => '', :null => false
    add_column :websites, :cardsave_password, :string, :default => '', :null => false
    add_column :websites, :cardsave_pre_shared_key, :string, :default => '', :null => false
  end
end
