class AddCachedNameWithAncestorsToPages < ActiveRecord::Migration[6.0]
  def change
    add_column :pages, :cached_name_with_ancestors, :string
  end
end
