class PreferredDeliveryDateSettings < ActiveRecord::Base
  belongs_to :website

  validates_inclusion_of :skip_bank_holidays, in: [true, false]
  validates_inclusion_of :skip_saturdays,     in: [true, false]
  validates_inclusion_of :skip_sundays,       in: [true, false]

  validates_inclusion_of :rfc2822_week_commencing_day,
    in: Time::RFC2822_DAY_NAME, allow_nil: true

  validates_inclusion_of :number_of_dates_to_show, in: 2..52

  validates_presence_of :website_id, :prompt, :date_format

  BANK_HOLIDAYS = [
    Date.new(2014, 4, 18),
    Date.new(2014, 4, 21),
    Date.new(2014, 5, 5),
    Date.new(2014, 5, 26),
    Date.new(2014, 8, 25),
    Date.new(2014, 12, 25),
    Date.new(2014, 12, 26),
    Date.new(2015, 1, 1),
    Date.new(2015, 4, 3),
    Date.new(2015, 4, 6),
    Date.new(2015, 5, 4),
    Date.new(2015, 5, 25),
    Date.new(2015, 8, 31),
    Date.new(2015, 12, 25),
    Date.new(2015, 12, 28)
  ]

  def options
    opts = ""
    dates().each do |d|
      opts += "<option>#{d.strftime(date_format)}</option>"
    end
    opts
  end

  # Returns <tt>true</tt> if <tt>date</tt> is included in <tt>#dates</tt>.
  def valid_date?(date)
    dates.include?(date)
  end

  def dates
    return week_commencing_dates unless rfc2822_week_commencing_day.nil?

    considered_date = first_valid_date
    found_dates = [considered_date]

    while found_dates.length < number_of_dates_to_show
      considered_date = considered_date.tomorrow
      if possible_date?(considered_date)
        found_dates << considered_date
      end
    end
    found_dates
  end

  def week_commencing_dates
    date = week_commencing first_valid_date
    found_dates = [date]
    while found_dates.length < number_of_dates_to_show
      date = date + 7.days
      found_dates << date
    end
    found_dates
  end

  def first_valid_date
    considered_date = Date.today
    initial_days_skipped = 0
    while true
      if possible_date?(considered_date)
        return considered_date if initial_days_skipped == number_of_initial_days_to_skip
        initial_days_skipped += 1
      end
      considered_date = considered_date.tomorrow
    end
  end

  def week_commencing date
    while(date.strftime('%a')!=rfc2822_week_commencing_day)
      date = date.yesterday
    end
    date
  end

  def possible_date?(date)
    return false if skip_saturdays and date.wday == 6
    return false if skip_sundays and date.wday == 0
    return false if skip_bank_holidays and bank_holiday? date
    true
  end

  def bank_holiday? date
    BANK_HOLIDAYS.include? date
  end
end
