class WorkEntriesController < ApplicationController

  before_filter :logged_in

  # GET /work_entries
  # GET /work_entries.json
  def index
    @order = params[:order] || session[:order] || 'desc'
    @order = 'desc' unless %w(asc desc).include?(@order.downcase) # default value; also avoids SQL hacks
    session[:order] = @order

    @year_month = (params[:year_month] || session[:year_month] || '').to_i
    session[:year_month] = @year_month

    admin_create_work_user_select_ivars

    query = WorkEntry.order("worked_at #{@order}")
    user_id = if @curr_user.admin?
                @work_user ? @work_user.id : nil
              else
                @curr_user.id
              end
    if @year_month != 0
      year, month = *year_month_int_to_year_and_month(@year_month)
      query = query.in_month(user_id, year, month)
    else
      query = query.where('user_id = ?', user_id) if user_id
    end

    @months = work_months_options(@work_user, true)

    @page = params[:page]
    @work_entries = query.page(@page)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @work_entries }
    end
  end

  # GET /work_entries/1
  # GET /work_entries/1.json
  def show
    @work_entry = WorkEntry.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @work_entry }
    end
  end

  # GET /work_entries/new
  # GET /work_entries/new.json
  def new
    @work_entry = WorkEntry.new
    @locations = Location.order(:name)
    @initial_codes = Code.where(location_id: @locations.first.id).all

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @work_entry }
    end
  end

  # GET /work_entries/1/edit
  def edit
    @work_entry = WorkEntry.find(params[:id])
    @locations = Location.order(:name)
    @initial_codes = Code.where(location_id: @work_entry.code.location.id).all
  end

  # POST /work_entries
  # POST /work_entries.json
  def create
    @work_entry = WorkEntry.new(duration_to_minutes(params[:work_entry]))

    respond_to do |format|
      if @work_entry.save
        format.html { redirect_to @work_entry, notice: 'Work entry was successfully created.' }
        format.json { render json: @work_entry, status: :created, location: @work_entry }
      else
        format.html { render action: "new" }
        format.json { render json: @work_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /work_entries/1
  # PUT /work_entries/1.json
  def update
    @work_entry = WorkEntry.find(params[:id])

    respond_to do |format|
      if @work_entry.update_attributes(duration_to_minutes(params[:work_entry]))
        format.html { redirect_to @work_entry, notice: 'Work entry was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @work_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /work_entries/1
  # DELETE /work_entries/1.json
  def destroy
    @work_entry = WorkEntry.find(params[:id])
    @work_entry.destroy

    respond_to do |format|
      format.html { redirect_to work_entries_url }
      format.json { head :ok }
    end
  end

  # Creates new hash with :minutes created by parsing that value as a string
  # from the incoming hash.
  def duration_to_minutes(param_hash)
    param_hash = param_hash.symbolize_keys
    param_hash[:minutes] = WorkEntry.duration_as_minutes(param_hash[:minutes])
    param_hash
  end

end
