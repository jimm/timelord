Mime::Type.register "application/pdf", :pdf

class InvoiceController < ApplicationController

  before_filter :logged_in

  def index
    admin_create_work_user_select_ivars(false)
    @months = work_months_options(@work_user, false)
  end

  def preview
    admin_create_work_user_ivars

    year = month = 0
    if params[:year_month]
      year, month = *year_month_int_to_year_and_month(params[:year_month].to_i)
    else
      year = params[:year].to_i
      month = params[:month].to_i
    end
    discount_pct = params[:discount_pct].to_i if params[:discount_pct]

    $stderr.puts "params[:year_month] = #{params[:year_month]}, year = #{year}, month = #{month}" # DEBUG
    user = @curr_user.admin? ? @work_user : @curr_user
    @inv = Invoice.generate(user, year, month, discount_pct)

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
