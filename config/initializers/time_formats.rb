class ActiveSupport::TimeWithZone
  def am_pm_format(strftime_args)
    strftime(strftime_args).gsub(/am/i, "a.m.").gsub(/pm/i, "p.m.")
  end

  # Mon, Jan 26
  def dow_short_date
    strftime("%a, %b %-d")
  end

  # Jan 26
  def short_date
    strftime("%b %-d")
  end

  # Jan 26 @  8:40 pm
  def short_date_at_time
    strftime("%b %-d @ %l:%M %P")
  end

  # 8:40 pm (Tue 1/26)
  def dow_time
    strftime("%a %l:%M %p").gsub('  ', ' ')
  end

  # 2023-01-26T20:40:30Z
  def picker_datetime
    strftime("%Y-%m-%dT%H:%M:%SZ")
  end

  # 2023-01-26
  def picker_date
    strftime("%Y-%m-%d")
  end

  # 8:40 pm (Tue 1/26)
  def time_and_day
    strftime("%l:%M %P (%a %-m/%-d)")
  end
end