class AddDeliveryInstructionsToBasket < ActiveRecord::Migration
  def change
    add_column :baskets, :delivery_instructions, :text
  end
end
