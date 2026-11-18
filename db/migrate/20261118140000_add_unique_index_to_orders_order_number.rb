class AddUniqueIndexToOrdersOrderNumber < ActiveRecord::Migration[8.1]
  # Payment callbacks and webhooks find orders by number, so it must be
  # unique even when two orders are created at the same time.
  def change
    add_index :orders, :order_number, unique: true
  end
end
