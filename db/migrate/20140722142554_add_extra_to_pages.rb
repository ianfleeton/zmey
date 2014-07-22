class AddExtraToPages < ActiveRecord::Migration
  def change
    add_column :pages, :extra, :text
  end
end
