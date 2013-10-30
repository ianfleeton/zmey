class AddContactDetailsToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :address_line_1, :string, default: '', null: false
    add_column :websites, :address_line_2, :string, default: '', null: false
    add_column :websites, :town_city, :string, default: '', null: false
    add_column :websites, :county, :string, default: '', null: false
    add_column :websites, :postcode, :string, default: '', null: false
    add_column :websites, :country_id, :integer, null: false
    add_column :websites, :phone_number, :string, default: '', null: false
    add_column :websites, :fax_number, :string, default: '', null: false
    add_column :websites, :twitter_username, :string, default: '', null: false
    add_column :websites, :skype_name, :string, default: '', null: false
  end
end
