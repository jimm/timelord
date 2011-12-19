class ApplicationController < ActionController::Base
  protect_from_forgery

  def load_curr_user
    uid = session[:user_id]
    @curr_user = User.find_by_id(uid) if uid
  end

  def logged_in
    load_curr_user
    redirect_to :controller => 'account', :action => 'login' unless @curr_user
  end
end
