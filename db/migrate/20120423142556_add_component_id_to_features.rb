class AddComponentIdToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :component_id, :integer
    add_index :features, :component_id
  end
end
