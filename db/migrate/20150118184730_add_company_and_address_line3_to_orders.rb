class AddCompanyAndAddressLine3ToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :billing_company, :string
    add_column :orders, :delivery_company, :string
    add_column :orders, :billing_address_line_3, :string
    add_column :orders, :delivery_address_line_3, :string
  end
end
