class RemoveDefaultCountryIdFromOrdersAndAddresses < ActiveRecord::Migration
  def up
    change_column_default :addresses, :country_id, nil
    change_column_default :orders, :country_id, nil
  end

  def down
    change_column_default :addresses, :country_id, 0
    change_column_default :orders, :country_id, 0
  end
end
