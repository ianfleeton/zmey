class AddBillingAddressDetailsToOrders < ActiveRecord::Migration
  class Order < ActiveRecord::Base
  end

  def change
    add_column :orders, :billing_full_name,      :string, default: '', null: false
    add_column :orders, :billing_address_line_1, :string, default: '', null: false
    add_column :orders, :billing_address_line_2, :string, default: '', null: false
    add_column :orders, :billing_town_city,      :string, default: '', null: false
    add_column :orders, :billing_county,         :string, default: '', null: false
    add_column :orders, :billing_postcode,       :string, default: '', null: false
    add_column :orders, :billing_country_id,     :integer,             null: false
    add_column :orders, :billing_phone_number,   :string, default: '', null: false

    Order.reset_column_information

    reversible do |dir|
      dir.up do
        columns = ['full_name', 'address_line_1', 'address_line_2',
          'town_city', 'county', 'postcode', 'country_id', 'phone_number']
        Order.update_all columns.map {|c| "billing_#{c}=delivery_#{c}"}
                                .join(',')
      end
    end
  end
end
