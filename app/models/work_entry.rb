class WorkEntry < ActiveRecord::Base

  belongs_to :code
  belongs_to :user

  scope :in_month, lambda { |user_id, year, month| where('user_id = ? and extract (year from worked_at) = ? and extract(month from worked_at) = ?', user_id, year, month) }

  # Return min year, min year month, max year, max year month
  def self.min_max_dates_for_user(user)
    sql = <<EOS
select min(worked_at), max(worked_at)
from #{table_name}
where user_id = #{user.id}
EOS
    min_str, max_str = *connection.query(sql).first
    min_str =~ /(\d{4})-(\d{2})-\d{2}/
    min_year, min_year_month = $1, $2
    max_str =~ /(\d{4})-(\d{2})-\d{2}/
    max_year, max_year_month = $1, $2
    [min_year.to_i, min_year_month.to_i, max_year.to_i, max_year_month.to_i]
  end

  # Converts minutes to a string like "d:hh:mm".
  def self.minutes_as_duration(minutes)
    return nil unless minutes
    val = minutes
    mins = val % 60
    val /= 60
    hours = val % 24
    val /= 24
    days = val

    str = '%02d' % mins
    if hours != 0
      if days == 0              # hours != 0, days == 0
        str = "#{hours}:#{str}"
      else                      # hours != 0, days != 0
        str = "#{'%02d' % hours}:#{str}"
      end
    elsif days == 0             # hours == 0, days == 0
      str = "0:#{str}"
    else                        # hours == 0, days != 0
      str = "00:#{str}"
    end

    if days != 0
      str = "#{days}:#{str}"
    end

    str
  end

  # Converts a string like "d:hh:mm" to minutes.
  def self.duration_as_minutes(dur)
    m, h, d = dur.split(/:/).reverse
    m.to_i + h.to_i * 60 + (d ? d.to_i * 60 * 24 : 0)
  end

  # Returns minutes as a string like "d:hh:mm".
  def minutes_as_duration
    WorkEntry.minutes_as_duration(self.minutes)
  end
end
