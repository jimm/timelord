require 'csv'
require 'prawn'
require 'application_helper'    # for money_str

class Invoice

  MONTHS = %w(huh January February March April May June July August September October November December)
  HEADERS = ['Location', 'Date', 'Code', 'Time', '$/Hour', 'Notes', 'Fee']
  PDF_HEADER_BG = 'eeeeee'
  PDF_LOCATION_BG = 'ddddff'
  PDF_RIGHT_JUSTIFY_COLS = [3, 4, 6]
  PDF_TOTALS_RIGHT_JUSTIFY_COLS = [2, 3]
  PDF_TOTALS_RIGHT_JUSTIFY_COLS_WITH_DISCOUNT = [2, 3, 4, 5]
  PDF_WORK_ENTRY_COL_WIDTHS = {1 => 60, 2 => 120, 3 => 40, 4 => 50, 6 => 50}

  # Note: if ApplicationHelper gets more methods, should probably extract
  # money_str from that class instead of including everything here.
  include ApplicationHelper

  attr_reader :user, :year, :month, :discount_pct, :work_entries

  def self.generate(user, year, month, discount_pct=0)
    inv = new(user, year, month, discount_pct)
    inv.generate
    inv
  end

  def initialize(user, year, month, discount_pct=0)
    @user, @year, @month, @discount_pct = user, year, month, discount_pct
  end

  def generate
    @work_entries = WorkEntry.in_month(@user ? @user.id : nil, @year, @month).all
    tmim = total_minutes_in_month()
    @work_entries.each { |w|
      w.rate_cents = @user.hourly_rate_cents(tmim)
      w.fee_cents = w.rate_cents * w.minutes / 60.0
    }
  end

  def invoice_number
    "#{@user.id}-#{(year - 2011) * 12 + month}"
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
    @work_entries.sum(:fee_cents)
  end

  def total_minutes_in_month
    @work_entries.sum(:minutes)
  end

  def total_minutes_for_code(code)
    @work_entries.select { |we| we.code == code }.sum(&:minutes)
  end

  def work_entries_at(location)
    @work_entries.select { |w| w.code.location == location }.sort_by(&:worked_at)
  end

  def discount?
    @discount_pct != nil && @discount_pct > 0
  end

  def discounted(amt_cents)
    if @discount_pct && @discount_pct > 0
      (amt_cents.to_f * (100.0 - @discount_pct.to_f) / 100.0).to_i
    else
      amt_cents
    end
  end

  def date_range_start
    "#{MONTHS[month]} 1"
  end

  def date_range_end
    "#{MONTHS[month]} #{Time.mktime(@year, @month, 1).end_of_month.day}"
  end

  def csv_download_file_name
    download_file_name('csv')
  end

  def pdf_download_file_name
    download_file_name('pdf')
  end

  def pdf_file_path
    "/tmp/timelord_#{MONTHS[month]}_#{year}_Invoice.pdf"
  end

  def download_file_name(extension)
    "#{MONTHS[month]} #{year} Invoice.#{extension}"
  end

  def to_csv
    CSV.generate do |csv|
      csv << csv_header
      csv << ['']
      csv_data.each { |row| csv << row }
      csv << ['']
      csv_totals.each { |row| csv << row }
    end
  end

  def csv_header
    ['', "#{@user.name} time from #{date_range_start} - #{date_range_end}, #{year}"]
  end

  def csv_data
    csv = []
    csv << HEADERS
    locations.each do |loc|
      csv << [loc.name]
      work_entries_at(loc).each do |w|
        csv << ['', w.worked_at, w.code.full_name, w.minutes_as_duration, money_str(w.rate_cents), w.note, money_str(w.fee_cents)]
      end
    end
    csv
  end

  def csv_totals
    csv = []
    headers = ['Location', 'Code', 'Hours', 'Subtotal']
    if discount?
      headers += ['Discount', 'Discounted']
    end
    csv << headers

    codes.each do | code|
      subtotal = code_subtotal(code)
      row = [code.location.name, code.full_name, WorkEntry.minutes_as_duration(total_minutes_for_code(code)), money_str(subtotal)]
      if discount?
        row += ["#{@discount_pct}%", money_str(discounted(subtotal))]
      end
      csv << row
    end

    row = ['', '', '', '']
    if discount?
      row += ['', '']
    end
    csv << row

    row = ['', 'Total', WorkEntry.minutes_as_duration(total_minutes_in_month), money_str(total)]
    if discount?
      row += ["#{@discount_pct}%", money_str(discounted(total))]
    end
    csv << row

    csv
  end

  # Write invoice to PDF and returns the path to that file
  def write_to_pdf
    path = pdf_file_path
    Prawn::Document.generate(path, :page_layout => :landscape) do |pdf|
      @pdf = pdf
      pdf_header
      pdf_footer

      @pdf.font_size 9
      @pdf.start_new_page
      pdf_main_table
      @pdf.start_new_page
      pdf_totals_table
    end
    path
  end

  def pdf_header
    str = <<EOS
#{@user.name}
#{@user.address.strip}
EOS
    str.each_line { |line| @pdf.text line, :style => :bold, :align => :center }
    @pdf.move_down 30
    str = <<EOS
Invoice  ##{invoice_number}
#{date_range_start}-#{date_range_end}, #{year}
EOS
    str.each_line { |line| @pdf.text line, :style => :bold, :align => :right }
    @pdf.move_down 100
    str = <<EOS
TO:
#{@user.invoice_recipient.strip}
EOS
    str.each_line { |line| @pdf.text line, :style => :bold }
  end

  def pdf_main_table
    data = csv_data

    # colorize headers
    data[0].each_with_index { |str, i| data[0][i] = @pdf.make_cell(:content => str, :background_color => PDF_HEADER_BG) }

    # colorize locations and change widths of cols
    data.each_with_index do |row, i|
      if row.length == 1
        row[0] = @pdf.make_cell(:content => row[0], :background_color => PDF_LOCATION_BG)
      end
    end
    
    # right-justify some columns
    data[1..-1].each_with_index do |row, i|
      unless row.length == 1
        PDF_RIGHT_JUSTIFY_COLS.each { |col| row[col] = @pdf.make_cell(:content => row[col], :align => :right) }
      end
    end

    col_widths = PDF_WORK_ENTRY_COL_WIDTHS
    @pdf.bounding_box [0, @pdf.bounds.height], :width => @pdf.bounds.width, :height => @pdf.bounds.height - 16 do
      @pdf.table(data, :header => true, :column_widths => col_widths)
    end
  end

  def pdf_totals_table
    data = csv_totals
    data[0].each_with_index { |str, i| data[0][i] = @pdf.make_cell(:content => str, :background_color => PDF_HEADER_BG) }
    data[-1][1] = @pdf.make_cell(:content => data[-1][1], :background_color => PDF_HEADER_BG)

    # right-justify some columns
    rjs = discount? ? PDF_TOTALS_RIGHT_JUSTIFY_COLS_WITH_DISCOUNT : PDF_TOTALS_RIGHT_JUSTIFY_COLS
    data[1..-1].each_with_index do |row, i|
      unless row.length == 1
        rjs.each { |col| row[col] = @pdf.make_cell(:content => row[col], :align => :right) }
      end
    end

    @pdf.table(data, :header => true)
  end

  def pdf_footer
    all_but_first_page = lambda { |pg| pg > 1 }

    @pdf.repeat(all_but_first_page) do
      @pdf.bounding_box [@pdf.bounds.left, 12], :width  => @pdf.bounds.width do
        @pdf.text "#{@user.name} / Invoice ##{invoice_number} / #{date_range_start} - #{date_range_end}, #{year}"
      end
    end

    opts = {
      :page_filter => all_but_first_page,
      :start_count_at => 2,
      :at => [@pdf.bounds.right - 90, 12]
    }
    @pdf.number_pages "Page <page> of <total>", opts
  end

end
