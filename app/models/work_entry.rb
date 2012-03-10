class WorkEntry < ActiveRecord::Base

  belongs_to :code
  belongs_to :user

  scope :in_month, lambda { |user_id, year, month|
    if user_id
      where('user_id = ? and extract (year from worked_at) = ? and extract(month from worked_at) = ?', user_id, year, month)
    else                        # used by admins only
      where('extract (year from worked_at) = ? and extract(month from worked_at) = ?', year, month)
    end
  }

  # Return min year, min year month, max year, max year month. If user is
  # nil, return min/max dates for all work entries.
  def self.min_max_dates_for_user(user)
    sql = "select min(worked_at), max(worked_at) from #{table_name}"
    if user
      sql << " where user_id = #{user.id}"
    end

    logger.debug "ABOUT TO SELECT"
    min_str, max_str = *connection.query(sql).first
    min_str =~ /(\d{4})-(\d{2})-\d{2}/
    min_year, min_year_month = $1, $2
    max_str =~ /(\d{4})-(\d{2})-\d{2}/
    max_year, max_year_month = $1, $2
    logger.debug [min_year.to_i, min_year_month.to_i, max_year.to_i, max_year_month.to_i].inspect # DEBUG
    logger.debug "ABOUT TO RETURN"
    [min_year.to_i, min_year_month.to_i, max_year.to_i, max_year_month.to_i]
  end

  # Converts minutes to a string like "d:hh:mm".
  def self.minutes_as_duration(minutes)
    return nil unless minutes
    mins = minutes % 60
    hours = minutes / 60
    "#{hours}:#{'%02d' % mins}"
  end

  # Converts a string like "d:hh:mm" to minutes.
  def self.duration_as_minutes(dur)
    m, h = dur.split(/:/).reverse
    m.to_i + h.to_i * 60
  end

  # Returns minutes as a string like "d:hh:mm".
  def minutes_as_duration
    WorkEntry.minutes_as_duration(self.minutes)
  end
end
