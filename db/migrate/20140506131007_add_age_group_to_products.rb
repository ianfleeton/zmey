class AddAgeGroupToProducts < ActiveRecord::Migration
  def change
    add_column :products, :age_group, :string, null: false, default: ''
  end
end
