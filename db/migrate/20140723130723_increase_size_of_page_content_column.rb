class IncreaseSizeOfPageContentColumn < ActiveRecord::Migration
  def up
    change_column :pages, :content, :text, limit: 16.megabytes
  end

  def down
    change_column :pages, :content, :text
  end
end
