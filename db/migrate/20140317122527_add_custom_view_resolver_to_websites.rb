class AddCustomViewResolverToWebsites < ActiveRecord::Migration
  def change
    add_column :websites, :custom_view_resolver, :string
  end
end
