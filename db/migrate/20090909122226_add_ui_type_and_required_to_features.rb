class AddUiTypeAndRequiredToFeatures < ActiveRecord::Migration
  def self.up
    add_column :features, :ui_type, :integer, :default => 0, :null => false
    add_column :features, :required, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :features, :required
    remove_column :features, :ui_type
  end
end
