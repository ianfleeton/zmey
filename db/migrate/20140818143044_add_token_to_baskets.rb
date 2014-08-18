class AddTokenToBaskets < ActiveRecord::Migration
  class Basket < ActiveRecord::Base
  end

  def change
    add_column :baskets, :token, :string, null: false
    Basket.reset_column_information
    reversible do |dir|
      dir.up do
        Basket.all.each do |basket|
          basket.update_attribute(:token, SecureRandom.urlsafe_base64(nil, false))
        end
      end 
    end
    add_index :baskets, :token, unique: true
  end
end
