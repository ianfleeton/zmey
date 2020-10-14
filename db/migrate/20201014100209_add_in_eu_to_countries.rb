class AddInEuToCountries < ActiveRecord::Migration[6.0]
  def change
    add_column :countries, :in_eu, :boolean, default: false, null: false
  end
end
