class AllowNullsForAddressLine2AndCountyAndPhone < ActiveRecord::Migration
  def up
    change_column :addresses, :address_line_2, :string, default: nil, null: true
    change_column :addresses, :county, :string, default: nil, null: true
    change_column :addresses, :phone_number, :string, default: nil, null: true

    change_column :orders, :billing_address_line_2, :string, default: nil, null: true
    change_column :orders, :billing_county, :string, default: nil, null: true
    change_column :orders, :billing_phone_number, :string, default: nil, null: true

    change_column :orders, :delivery_address_line_2, :string, default: nil, null: true
    change_column :orders, :delivery_county, :string, default: nil, null: true
    change_column :orders, :delivery_phone_number, :string, default: nil, null: true
  end

  def down
    change_column :addresses, :address_line_2, :string, default: '', null: false
    change_column :addresses, :county, :string, default: '', null: false
    change_column :addresses, :phone_number, :string, default: '', null: false

    change_column :orders, :billing_address_line_2, :string, default: '', null: false
    change_column :orders, :billing_county, :string, default: '', null: false
    change_column :orders, :billing_phone_number, :string, default: '', null: false

    change_column :orders, :delivery_address_line_2, :string, default: '', null: false
    change_column :orders, :delivery_county, :string, default: '', null: false
    change_column :orders, :delivery_phone_number, :string, default: '', null: false
  end
end
