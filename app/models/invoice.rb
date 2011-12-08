class Invoice

  MONTHS = %w(huh January February March April May June July August September October November December)

  attr_reader :year, :month, :work_entries, :total

  def self.generate(year, month)
    inv = new(year, month)
    inv.generate
    inv
  end

  def initialize(year, month)
    @year, @month = year, month
  end

  def generate
    @work_entries = WorkEntry.in_month(@year, @month).all
    @total
    @work_entries.each { |w|
      w.rate_cents = 10000
      w.fee_cents = w.rate_cents * w.minutes / 60
    }
  end

  def locations
    @work_entries.collect(&:code).uniq.collect(&:location).uniq.sort_by(&:id)
  end

  def work_entries_at(location)
    @work_entries.select { |w| w.code.location == location }.sort_by(&:worked_at)
  end

  def date_range_start
    "#{MONTHS[month]} 1"
  end

  def date_range_end
    "#{MONTHS[month]} #{Time.mktime(@year, @month, 1).end_of_month.day}"
  end

end
