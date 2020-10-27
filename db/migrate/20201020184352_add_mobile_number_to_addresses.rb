class AddMobileNumberToAddresses < ActiveRecord::Migration[6.0]
  def change
    add_column :addresses, :mobile_number, :string
  end
end
