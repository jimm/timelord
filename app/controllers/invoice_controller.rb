class InvoiceController < ApplicationController

  def index
  end

  def preview
    @inv = Invoice.generate(params[:year].to_i, params[:month].to_i)

    respond_to do |format|
      format.html # preview.html.erb
      format.csv { send_data(@inv.to_csv, :type => 'text/csv; charset=utf-8; header=present', :filename => @inv.csv_file_name) }
    end
  end

end
