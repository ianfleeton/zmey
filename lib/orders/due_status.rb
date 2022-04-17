# frozen_string_literal: true

module Orders
  # Helper methods for finding orders by their due status and categorising an
  # order by its due status. Orders can either be due, overdue or not-yet-due.
  class DueStatus
    attr_reader :today

    def initialize(website: nil, today: Date.current, includes: [])
      @today = today
      @website = website
      includes << :collection_ready_emails
      @includes = includes
    end

    def due_orders
      due_status_matching(:due)
    end

    def overdue_orders
      due_status_matching(:overdue)
    end

    def upcoming_orders
      due_status_matching(:upcoming)
    end

    def outstanding_orders
      possibly_due
    end

    # Returns the due status for an individual order.
    def due_status_for(order)
      due_status(due_dispatch_date(order))
    end

    # Returns a CSS class representing the due status with respect to the
    # order's relevant delivery date.
    def due_status_class(order)
      if due_status?(order)
        {
          overdue: "order-danger",
          due: "order-warning",
          not_yet_due: "order-success",
          upcoming: "order-success",
          none: nil
        }.fetch(due_status_for(order))
      end
    end

    # Returns the order's dispatch date, if set, or works back from the
    # relevant delivery date to find a dispatch date. May return +nil+ if the
    # delivery date is invalid and so there is no corresponding dispatch date.
    def due_dispatch_date(order)
      order.dispatch_date || Shipping::OrderDispatchDelivery.new(
        order, cutoff: website.delivery_cutoff_hour
      ).dispatch_date
    end

    # Returns +true+ if the order should be considered as having a due status.
    # If the order is not shippable or collectable, or if it's already been shipped, or if it
    # has no relevant delivery date then a due status is not applicable.
    def due_status?(order)
      order.relevant_delivery_date &&
        (order.shippable? || order.collectable?) &&
        !order.shipped_at &&
        order.collection_ready_emails.empty?
    end

    # Returns a symbol representing the due status with respect to how many days
    # differences there is between +date+ (the date of dispatch) and today.
    # Returns:
    #   :overdue when +date+ is in the past
    #   :due when +date+ is today
    #   :upcoming when +date+ is tomorrow, or Monday in the case of today being
    #   a Saturday
    #   :not_yet_due when +date+ later than that for :upcoming
    def due_status(date)
      return :none if date.nil?

      days = (date - today).to_i

      if days > 1
        days -= 1 if today.saturday?
        days -= 2 if today.friday?
      end

      if days > 1
        :not_yet_due
      elsif days == 1
        :upcoming
      elsif days == 0
        :due
      else
        :overdue
      end
    end

    # Returns an alphabetically sorted list of an order's departments (location names).
    def departments(order)
      order.locations.order(:name).distinct.pluck(:name)
    end

    def departments_summary(orders)
      summary = Hash.new(0)
      orders.each do |order|
        departments(order).each do |dept|
          summary[dept] += 1
        end
      end
      summary
    end

    def website
      @website ||= Website.first || Website.new
    end

    def due_status_matching(*statuses)
      possibly_due.select do |o|
        dispatch_date = due_dispatch_date(o)
        due_status?(o) && dispatch_date && statuses.index(due_status(dispatch_date))
      end
    end

    private

    def possibly_due
      Order
        .includes(@includes)
        .where(collection_ready_emails: {id: nil})
        .or(
          Order.includes(@includes)
          .where.not(shipping_method: ShippingClass::COLLECTION)
        )
        .where(completed_at: nil, shipped_at: nil)
        .where(
          "paid_on IS NOT NULL OR status = ?",
          Enums::PaymentStatus::PAYMENT_ON_ACCOUNT
        )
        .where("orders.updated_at > ?", (today - 62.day).to_fs(:db))
    end
  end
end
