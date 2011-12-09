require 'csv'

class Invoice

  MONTHS = %w(huh January February March April May June July August September October November December)

  attr_reader :year, :month, :work_entries, :total

  def self.generate(year, month)
    inv = new(year, month)
    inv.generate
    inv
  end

  def self.money_str(cents)
    ms = '%03d' % cents
    dollars, cents = ms[0..-3], ms[-2..-1]
    cents = cents.to_i || 0
    dollars = dollars.reverse.gsub(/(\d\d\d)/, '\1,').reverse.sub(/^,/, '')
    dollars = '0' if dollars == ''
    "$#{dollars}.#{'%02d' % cents.to_i}"
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
    codes.collect(&:location).uniq.sort_by(&:id)
  end

  def codes
    @work_entries.collect(&:code).uniq.sort_by(&:full_name)
  end

  def code_subtotal(code)
    @work_entries.sum { |w| w.code == code ? w.fee_cents : 0 }
  end

  def total
    @work_entries.sum(&:fee_cents)
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

  def money_str(cents)
    Invoice.money_str(cents)
  end

  def csv_file_name
    "#{MONTHS[month]} #{year} Invoice.csv"
  end

  def to_csv
    CSV.generate do |csv|
      csv << ['', "Menard time from #{date_range_start} - #{date_range_end} #{year}"]
      csv << ['']
      csv << ['Location', 'Date', 'Code', 'Time Spent', '$/Hour', 'Notes', 'Fee']
      locations.each do |loc|
        csv << [loc.name]
        work_entries_at(loc).each do |w|
          csv << ['', w.worked_at, w.code.full_name, w.minutes_as_duration, money_str(w.rate_cents), w.note, money_str(w.fee_cents)]
        end
      end
      csv << ['']
      csv << ['Location', 'Code', 'Subtotal']
      codes.each do | code|
        csv << [code.location.name, code.full_name, money_str(code_subtotal(code))]
      end
      csv << ['']
      csv << ['', 'Total', money_str(total)]
    end
  end

end
