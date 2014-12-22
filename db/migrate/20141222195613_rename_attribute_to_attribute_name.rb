class RenameAttributeToAttributeName < ActiveRecord::Migration
  def change
    rename_column :extra_attributes, :attribute, :attribute_name
  end
end
