class AddNoFollowAndNoIndexToPages < ActiveRecord::Migration
  def change
    add_column :pages, :no_follow, :boolean, null: false, default: false
    add_column :pages, :no_index,  :boolean, null: false, default: false
  end
end
