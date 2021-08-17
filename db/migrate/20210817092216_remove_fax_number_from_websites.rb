class RemoveFaxNumberFromWebsites < ActiveRecord::Migration[6.1]
  def change
    remove_column :websites, :fax_number
  end
end
