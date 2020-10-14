# frozen_string_literal: true

class CollectionReadyEmail < ApplicationRecord
  # Hour of the day in local (i.e., Europe/London) timezone.
  MINIMUM_SEND_TIME = 18

  # Associations
  belongs_to :order

  # Returns true if it is applicable to send a collection ready email for this
  # order.
  def self.applicable?(order)
    order.collectable? && order.collection_ready_emails.none?
  end

  # Enqueues a new collection ready email to be sent soon.
  def self.enqueue(order)
    CollectionReadyEmail.create!(
      order: order
    )
  end
end
