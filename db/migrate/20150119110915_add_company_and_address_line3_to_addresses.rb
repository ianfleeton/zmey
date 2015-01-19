class AddCompanyAndAddressLine3ToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :company, :string
    add_column :addresses, :address_line_3, :string
  end
end
