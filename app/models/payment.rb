class Payment < ActiveRecord::Base
  belongs_to :order, optional: true
  after_save :notify_order

  def notify_order
    order.try(:payment_accepted, self) if accepted?
  end
end
