Mime::Type.register "application/pdf", :pdf

class InvoiceController < ApplicationController

  MONTHS = %w(January February March April May June July August September October November December)

  before_filter :logged_in

  def index
    min_year, min_year_month, max_year, max_year_month = WorkEntry.min_max_dates_for_user(@curr_user)
    @months = (min_year * 12 + (min_year_month-1) .. max_year * 12 + (max_year_month-1)).collect { |year_month|
      year = year_month / 12
      month = year_month % 12
      ["#{year} #{MONTHS[month]}", year_month]
    }.reverse
  end

  def preview
    year = params[:year_month].to_i / 12
    month = (params[:year_month].to_i % 12) + 1
    @inv = Invoice.generate(@curr_user, year, month)

    respond_to do |format|
      format.html # preview.html.erb
      format.csv {
        send_data(@inv.to_csv, :type => 'text/csv; charset=utf-8; header=present', :filename => @inv.csv_download_file_name)
      }
      format.pdf {
        path = @inv.write_to_pdf
        send_file(path, :type => 'application/pdf; charset=utf-8', :filename => @inv.pdf_download_file_name)
        File.unlink(path)
      }
    end
  end

end
