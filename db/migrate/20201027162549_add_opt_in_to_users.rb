class AddOptInToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :opt_in, :boolean, default: true, null: false
  end
end
