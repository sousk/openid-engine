require 'openid_engine/acts_as_rp'
class SessionsController < ApplicationController
  include OpenidEngine::ActsAsRp
  
  # before_filter :catch_openid_request
  skip_before_filter :login_required
  
  # render new.rhtml
  def new
  end
  
  def show
    openid_authentication if openid_request?
  end
  
  def create
    if openid_request?
      openid_authentication
    else
      password_authentication unless openid_request?
    end
  end
  
  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default(new_session_path)
  end
  
  
  private
  def openid_authentication
    $LOGGER = logger
    process_openid_request :return_to => session_url
  end
  
  def password_authentication
    self.current_user = User.authenticate(params[:login], params[:password])
    if logged_in?
      if params[:remember_me] == "1"
        current_user.remember_me unless current_user.remember_token?
        cookies[:auth_token] = { :value => self.current_user.remember_token , :expires => self.current_user.remember_token_expires_at }
      end
      redirect_back_or_default(session_path)
      flash[:notice] = "Logged in successfully"
    else
      flash[:notice] = "wrong login or password"
      render :action => 'new'
    end
  end
end
