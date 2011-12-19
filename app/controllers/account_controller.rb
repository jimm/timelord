class AccountController < ApplicationController

  before_filter :curr_user?, :except => [:login, :logout]

  # GET /login
  # POST /login
  def login
    $stderr.puts "login, params[:login] = #{params[:login]}" # DEBUG
    if params[:login]
      @curr_user = User.authenticate(params[:login], params[:password])
      if @curr_user
        session[:user_id] = @user.id
        redirect_to @curr_user.admin? ? '/nav/' : '/'
      else
        flash[:errors] = ['User with that login name and password not found']
      end
    end
  end

  def logout
    session[:user_id] = nil
    redirect_to :action => 'login'
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    params[:user][:address].strip!
    @user = User.find(params[:id])
    params[:user].delete(:role)

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to @user, notice: 'Successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def curr_user?
    load_curr_user
    redirect_to(:back) unless params[:id].to_i == @curr_user.id
  end

end
