class RenameAddressDetailsToDeliveryAddressDetails < ActiveRecord::Migration
  def change
    rename_column :orders, :full_name,      :delivery_full_name
    rename_column :orders, :address_line_1, :delivery_address_line_1
    rename_column :orders, :address_line_2, :delivery_address_line_2
    rename_column :orders, :town_city,      :delivery_town_city
    rename_column :orders, :county,         :delivery_county
    rename_column :orders, :postcode,       :delivery_postcode
    rename_column :orders, :country_id,     :delivery_country_id
    rename_column :orders, :phone_number,   :delivery_phone_number
  end
end
