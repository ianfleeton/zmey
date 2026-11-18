class ReplaceUserSha1PasswordsWithBcrypt < ActiveRecord::Migration[8.1]
  # SHA1 hashes can't be converted to bcrypt, so existing passwords are
  # discarded and customers must set a new one via forgot password.
  def change
    remove_column :users, :encrypted_password, :string
    remove_column :users, :salt, :string
    add_column :users, :password_digest, :string
  end
end
