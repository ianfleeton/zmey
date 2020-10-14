class AddCodeAndUsesRemainingToDiscounts < ActiveRecord::Migration[6.0]
  def change
    add_column :discounts, :code, :string
    add_column :discounts, :uses_remaining, :integer
  end
end
