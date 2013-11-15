class AllowPagePositionToBeNull < ActiveRecord::Migration
  def up
    change_column :pages, :position, :integer, default: 0, null: true
  end

  def down
    change_column :pages, :position, :integer, default: 0, null: false
  end
end
