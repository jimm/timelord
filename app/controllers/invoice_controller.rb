class InvoiceController < ApplicationController

  def index
  end

  def generate
    inv = Invoice.generate(params[:year].to_i, params[:month].to_i)
  end

end
