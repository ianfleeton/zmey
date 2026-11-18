class RemoveForgotPasswordTokenFromUsers < ActiveRecord::Migration[8.1]
  # Reset tokens now come from has_secure_password and aren't stored.
  def change
    remove_column :users, :forgot_password_token, :string, default: "", null: false
  end
end
