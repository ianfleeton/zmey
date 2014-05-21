class AddLabelToAddresses < ActiveRecord::Migration
  def change
    add_column :addresses, :label, :string, null: false
  end
end
