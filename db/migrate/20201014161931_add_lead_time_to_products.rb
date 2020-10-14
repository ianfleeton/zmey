class AddLeadTimeToProducts < ActiveRecord::Migration[6.0]
  def change
    add_column :products, :lead_time, :integer, default: 1, null: false
  end
end
