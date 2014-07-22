class IncreaseSizeOfPageExtraColumn < ActiveRecord::Migration
  def up
    change_column :pages, :extra, :text, limit: 16.megabytes
  end

  def down
    change_column :pages, :extra, :text
  end
end
