class CodesController < ApplicationController

  before_filter :admin_logged_in

  # GET /codes
  # GET /codes.json
  def index
    @codes = Code.display_order.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @codes }
    end
  end

  # GET /codes/1
  # GET /codes/1.json
  def show
    @code = Code.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @code }
    end
  end

  # GET /codes/new
  # GET /codes/new.json
  def new
    @code = Code.new
    @locations = Location.order(:name)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @code }
    end
  end

  # GET /codes/1/edit
  def edit
    @code = Code.find(params[:id])
    @locations = Location.order(:name)
  end

  # POST /codes
  # POST /codes.json
  def create
    @code = Code.new(params.permit(:code))

    respond_to do |format|
      if @code.save
        format.html { redirect_to @code, notice: 'Code was successfully created.' }
        format.json { render json: @code, status: :created, location: @code }
      else
        format.html { render action: "new" }
        format.json { render json: @code.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /codes/1
  # PUT /codes/1.json
  def update
    @code = Code.find(params[:id])

    respond_to do |format|
      if @code.update_attributes(params.permit(:code))
        format.html { redirect_to @code, notice: 'Code was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @code.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /codes/1
  # DELETE /codes/1.json
  def destroy
    @code = Code.find(params[:id])
    @code.destroy

    respond_to do |format|
      format.html { redirect_to codes_url }
      format.json { head :ok }
    end
  end
end
