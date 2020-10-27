class AddExplicitOptInAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :explicit_opt_in_at, :datetime
  end
end
