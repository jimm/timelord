class ApplicationController < ActionController::Base

  MONTHS = %w(January February March April May June July August September October November December)

  protect_from_forgery

  def load_curr_user
    uid = session[:user_id]
    @curr_user = User.find_by_id(uid) if uid
  end

  def logged_in
    load_curr_user
    redirect_to :controller => 'account', :action => 'login' unless @curr_user
  end

  def admin_logged_in
    load_curr_user
    redirect_to :controller => 'account', :action => 'login' unless @curr_user && @curr_user.admin?
  end

  # Return select options for all months between current user's start and
  # end work entry dates. If +include_all+ is true, prepend an "All" option.
  def work_months_options(include_all=false)
    min_year, min_year_month, max_year, max_year_month = WorkEntry.min_max_dates_for_user(@curr_user)
    months = (year_and_month_to_int(min_year, min_year_month) .. year_and_month_to_int(max_year, max_year_month)).collect { |year_month|
      [year_month_int_to_str(year_month), year_month]
    }.reverse
    months = [['All', '']] + months if include_all
    months
  end

  # Given a year an month, turn them into a single int value.
  def year_and_month_to_int(year, month)
    (year * 12) + (month - 1)
  end

  # Given a year_month integer value, return a string of the form "YYYY
  # Monthname".
  def year_month_int_to_str(year_month)
    "#{year_month / 12} #{MONTHS[year_month % 12]}"
  end

  # Given a year_month integer value, return the year and month encoded
  # therein.
  def year_month_int_to_year_and_month(year_month)
    [year_month / 12, (year_month % 12) + 1]
  end
end
