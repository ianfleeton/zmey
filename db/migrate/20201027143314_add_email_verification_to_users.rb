class AddEmailVerificationToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :email_verification_token, :string
    add_column :users, :email_verified_at, :datetime
  end
end
