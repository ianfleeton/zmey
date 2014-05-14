class AddCustomerNoteToBaskets < ActiveRecord::Migration
  def change
    add_column :baskets, :customer_note, :text
  end
end
