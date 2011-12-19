class ApplicationController < ActionController::Base
  protect_from_forgery

  def logged_in
    uid = session[:user_id]
    @user = User.find_by_id(uid) if uid
    redirect_to :controller => 'users', :action => 'login' unless @user
  end
end
