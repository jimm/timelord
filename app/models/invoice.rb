class Invoice

  attr_accessor :year, :month, :work_entries

  def self.generate(year, month)
    new(year, month).generate
  end

  def initialize(year, month)
    @year, @month = year, month
  end

  def generate
    @work_entries = WorkEntry.in_month(@year, @month)
  end

end
