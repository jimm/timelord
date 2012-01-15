Mime::Type.register "application/pdf", :pdf

class InvoiceController < ApplicationController

  before_filter :logged_in

  def index
    @months = work_months_options
  end

  def preview
    year, month = *year_month_int_to_year_and_month(params[:year_month].to_i)
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
