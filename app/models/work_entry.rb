class WorkEntry < ActiveRecord::Base

  belongs_to :code
  belongs_to :user

  scope :in_month, lambda { |year, month| where('extract (year from worked_at) = ? and extract(month from worked_at) = ?', year, month) }

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
    dur =~ /(?:(\d+):)?(\d+):(\d+)/
    d, h, m = $1, $2, $3
    m.to_i + h.to_i * 60 + (d ? d.to_i * 60 * 24 : 0)
  end

  # Returns minutes as a string like "d:hh:mm".
  def minutes_as_duration
    WorkEntry.minutes_as_duration(self.minutes)
  end
end
